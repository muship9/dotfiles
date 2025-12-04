# TypeScript補完トラブルシューティングガイド

## 概要

このドキュメントは、NeovimでTypeScript/JavaScriptの補完が途中で効かなくなる問題の診断と対処法をまとめたものです。

## 実施した修正内容（2024年）

以下の修正を実施済み：

1. **補完タイムアウトの延長**: 2秒 → 5秒
   - ファイル: `nvim/lua/plugins/lsp.lua:963`
   - 複雑な型推論でも補完が完了するように

2. **node_modules除外設定の追加**
   - ファイル: `nvim/lua/plugins/lsp.lua:864-873`
   - tsserverのメモリ・CPU使用量を削減

3. **大規模ファイル検出閾値の調整**: 8MB → 2MB
   - ファイル: `nvim/lua/config/autocmds.lua:128`
   - より早く大規模ファイルを検出して補完を無効化

4. **診断設定遅延の短縮**: 300ms → 100ms
   - ファイル: `nvim/lua/config/autocmds.lua:234`
   - LSPアタッチと診断設定のタイミングずれを最小化

---

## 問題が再発した場合の確認ポイント

### 1. LSPサーバーの状態確認

#### `:LspInfo`
現在アタッチされているLSPサーバーを確認：
- tsserverが正常に動作しているか
- エラーメッセージが出ていないか

#### `:checkhealth`
Neovim全体の健全性チェック：
- LSP関連の問題を検出

### 2. ログの確認

#### LSPログを有効化
```vim
:lua vim.lsp.set_log_level("debug")
```

#### ログファイルの場所を確認
```vim
:lua print(vim.lsp.get_log_path())
```
通常は `~/.local/state/nvim/lsp.log`

#### ログをリアルタイムで確認
```bash
tail -f ~/.local/state/nvim/lsp.log
```

### 3. メモリ・パフォーマンス確認

#### プロジェクトサイズをチェック
```bash
# TypeScriptファイル数
find . -name "*.ts" -o -name "*.tsx" | wc -l

# node_modulesのサイズ
du -sh node_modules

# プロジェクト全体のサイズ
du -sh .
```

#### tsserverプロセスを確認
```bash
ps aux | grep tsserver
# メモリ使用量（RSS列）をチェック
```

---

## 症状別の診断

### 補完が全く出ない

**原因**:
- LSPサーバー未アタッチ
- ファイルが2MB以上で大規模ファイル検出により無効化

**確認方法**:
```vim
" LSPサーバーの状態
:LspInfo

" 大規模ファイルフラグの確認
:lua print(vim.b.large_file)
```

**対処法**:
```vim
:LspRestart
```

### 補完が途中で止まる

**原因**:
- タイムアウト（5秒以内に結果が返らない）
- 複雑な型推論

**確認方法**:
```bash
grep -i "timeout" ~/.local/state/nvim/lsp.log | tail -20
```

**対処法**:
- `fetching_timeout`を5秒 → 10秒に延長
- プロジェクトを分割して開く

### 補完が遅い

**原因**:
- node_modules除外が効いていない
- メモリ不足

**確認方法**:
```bash
# LSPログでnode_modules内のファイルが処理されていないか確認
grep "node_modules" ~/.local/state/nvim/lsp.log
```

**対処法**:
- `tsserver_max_memory`を8GB → 12GBに増やす
- モノレポの場合はサブプロジェクトごとに開く

### 一時的に復活してまた止まる

**原因**:
- tsserverのクラッシュ → 再起動を繰り返している

**確認方法**:
```bash
ps aux | grep tsserver
# 何度か実行してプロセスIDが変わるか確認
```

**対処法**:
```vim
:LspRestart
```
ログを確認してクラッシュ原因を特定

---

## LSPは生きているのに補完が効かない場合

`:LspInfo`でtsserverが動作しているのに補完が効かないケースは、**補完パイプラインのどこかで詰まっている**状態です。

### 考えられる原因

#### 1. nvim-cmpとLSPの連携が切れている

**確認方法**:
```vim
" 補完ソースの状態を確認
:lua print(vim.inspect(require('cmp').get_config().sources))

" LSPから補完候補が来ているか確認（Insert modeで実行）
:lua print(vim.inspect(vim.lsp.buf_request_sync(0, 'textDocument/completion', vim.lsp.util.make_position_params(), 5000)))
```

#### 2. tsserverがindexing中/ビジー状態

tsserverはプロジェクト読み込み直後や大規模プロジェクトで、バックグラウンドでインデックス作成中の可能性があります。

**症状**:
- ファイルを開いた直後は補完が効かない
- 数秒〜数分待つと復活する
- 大規模プロジェクトで頻発

**確認方法**:
```bash
tail -f ~/.local/state/nvim/lsp.log | grep -i "configFileDiag\|projectLoad\|indexing"
```

#### 3. 特定のコンテキストで補完が返らない

tsserverは動いているが、特定の場所で補完情報を生成できない（循環参照、型エラーが多い、any型など）。

**確認方法**:
```vim
" カーソル位置で補完を手動リクエスト
:lua vim.lsp.buf.completion()

" または診断情報を見る
:lua vim.diagnostic.open_float()
```

#### 4. タイムアウトしている（静かに失敗）

リクエストは送られているが、5秒以内に結果が返ってこない。

**確認方法**:
```bash
grep -i "timeout\|request.*completion" ~/.local/state/nvim/lsp.log | tail -20
```

#### 5. tsconfig.jsonの問題

tsserverは起動しているが、プロジェクト設定の問題で特定のファイルを認識していない。

**確認方法**:
```bash
# プロジェクトルートにtsconfig.jsonがあるか
ls tsconfig.json

# ファイルがtsconfig.jsonのinclude対象か確認
```

### デバッグ手順

#### ステップ1: 補完リクエストが送られているか確認

Insert modeで以下を実行：
```vim
:lua vim.lsp.set_log_level("debug")
```

その後、補完を試みてログを確認：
```bash
tail -50 ~/.local/state/nvim/lsp.log | grep "textDocument/completion"
```

- リクエストが**送られていない** → nvim-cmpの設定問題
- リクエストが**送られている** → tsserverの応答問題

#### ステップ2: 手動で補完を強制実行

```vim
" Insert modeで
<C-x><C-o>  " omnifuncで補完（LSP直接）

" または
<C-Space>   " nvim-cmpのトリガー
```

- `<C-x><C-o>`で出る → nvim-cmpの問題
- `<C-x><C-o>`でも出ない → LSPの問題

#### ステップ3: LSPの応答速度を確認

```vim
:lua vim.lsp.buf_request(0, 'textDocument/completion', vim.lsp.util.make_position_params(), function(err, result) print(vim.inspect({err=err, result=result})) end)
```

すぐに結果が返れば問題なし、何も返らなければタイムアウト。

---

## 即効性のある対処法

### 対処1: LSP再起動
```vim
:LspRestart
```

### 対処2: 補完を手動トリガー
```vim
" Insert modeで
<C-Space>
```

### 対処3: nvim-cmpをリセット
```vim
:lua require('cmp').setup.buffer({ enabled = false })
:lua require('cmp').setup.buffer({ enabled = true })
```

### 対処4: ファイルを開き直す
```vim
:e!
```

### 対処5: Neovim再起動
```vim
:qa!
```

---

## デバッグコマンド集

```vim
" LSPサーバー情報
:LspInfo

" LSPを再起動
:LspRestart

" 補完を手動トリガー（Insert mode）
<C-Space>

" omnifuncで補完（Insert mode）
<C-x><C-o>

" 診断情報を表示
:lua vim.diagnostic.open_float()

" バッファのLSPクライアント一覧
:lua print(vim.inspect(vim.lsp.get_active_clients()))

" 現在のファイルサイズ確認
:lua print(vim.fn.getfsize(vim.fn.expand('%')))

" 大規模ファイルフラグ確認
:lua print(vim.b.large_file)

" LSPログレベルを設定
:lua vim.lsp.set_log_level("debug")  -- trace, debug, info, warn, error

" LSPログパスを確認
:lua print(vim.lsp.get_log_path())

" 補完ソースの状態確認
:lua print(vim.inspect(require('cmp').get_config().sources))
```

---

## よくある原因と確認方法

| 症状 | 原因 | 確認方法 |
|------|------|----------|
| 補完が出ない | LSP未アタッチ | `:LspInfo` |
| 途中で止まる | タイムアウト | LSPログで`timeout`検索 |
| メモリ不足 | tsserverクラッシュ | `ps aux \| grep tsserver` |
| 極端に遅い | node_modules未除外 | LSPログでファイルパス確認 |
| 2MB以上のファイル | 大規模ファイル検出 | `:lua print(vim.b.large_file)` |
| indexing中 | プロジェクト読み込み中 | LSPログで`indexing`検索 |

---

## 設定調整が必要な場合

### 補完タイムアウトを延長

**ファイル**: `nvim/lua/plugins/lsp.lua`

```lua
performance = {
  fetching_timeout = 10000, -- 5000 → 10000に延長
}
```

### メモリ上限を増やす

**ファイル**: `nvim/lua/plugins/lsp.lua`

```lua
settings = {
  tsserver_max_memory = 12288, -- 8192 → 12288 (12GB)
}
```

### 大規模ファイル閾値を調整

**ファイル**: `nvim/lua/config/autocmds.lua`

```lua
local max_filesize = 1024 * 1024 * 4 -- 2MB → 4MBに緩和
```

---

## トラブルシューティングフロー

```
補完が効かない
  ├─ :LspInfo を実行
  │   ├─ tsserver未アタッチ → :LspRestart
  │   └─ tsserverアタッチ済み
  │       ├─ :lua print(vim.b.large_file)
  │       │   └─ true → ファイルが2MB以上（仕様）
  │       ├─ <C-x><C-o> で補完を試す
  │       │   ├─ 出る → nvim-cmpの問題
  │       │   └─ 出ない → LSPの問題
  │       │       ├─ LSPログを確認
  │       │       │   ├─ timeout → タイムアウト延長
  │       │       │   ├─ indexing → 待つ
  │       │       │   └─ error → エラー内容を確認
  │       │       └─ :LspRestart で復旧を試みる
  └─ それでもダメ → Neovim再起動
```

---

## 参考情報

### 関連ファイル

- LSP設定: `nvim/lua/plugins/lsp.lua`
- 自動コマンド: `nvim/lua/config/autocmds.lua`
- LSPログ: `~/.local/state/nvim/lsp.log`

### 修正履歴

- 2024年: TypeScript補完問題の修正実施
  - 補完タイムアウト延長（2秒→5秒）
  - node_modules除外設定追加
  - 大規模ファイル検出閾値調整（8MB→2MB）
  - 診断設定遅延短縮（300ms→100ms）
