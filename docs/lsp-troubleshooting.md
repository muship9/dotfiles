# LSP トラブルシューティングガイド

## 症状：LSPが応答しなくなる

### よくある症状
- コードジャンプ時に `[Fzf-lua] LSP: no client attached` エラーが表示される
- オートコンプリートが動作しない
- 診断（エラー・警告）が表示されない
- 数分使用後、または一定時間アイドル状態の後に発生
- すべてのファイルタイプで発生する可能性がある

## 即座に復旧する方法

### TypeScriptファイルの場合
```vim
:TSRestart
```

### その他のファイルタイプ
```vim
:LspRestart
```

## 診断コマンド

### 1. 現在の状態を確認
```vim
:LspInfo
```
アタッチされているLSPクライアントの一覧が表示されます。

### 2. TypeScript固有の状態確認
```vim
:TSStatus
```
Node.jsとTypeScriptライブラリのパスを確認できます。

### 3. 詳細なデバッグ情報
```vim
:LspDebug
```
以下の情報が表示されます：
- 現在のファイルタイプ
- バッファ番号
- 診断の有効/無効状態
- アタッチされているLSPクライアント
- 診断情報の数

### 4. LSPログの確認
```vim
:lua vim.cmd('e ' .. vim.fn.stdpath('log') .. '/lsp.log')
```
ファイルを開いたら `G` で最後に移動し、`ERROR` や `WARN` を探します。

### 5. アタッチされているクライアントを確認
```vim
:lua for _, client in ipairs(vim.lsp.get_clients({bufnr = 0})) do print(client.name) end
```

## よくある原因と対策

### 1. CursorHold イベントでの過負荷
**原因**: カーソルが止まるたびに診断フロートを自動表示する設定が、LSPに過度な負荷をかける

**対策**: `nvim/lua/plugins/lsp.lua` の452行目付近のCursorHold autocmdを無効化（コメントアウト）

診断を手動で表示するには：
- `<leader>d` - 診断フロート表示
- `<leader>cd` - フォーカス付き診断フロート表示
- `[d` - 前の診断へ移動
- `]d` - 次の診断へ移動

### 2. TypeScript Tools の設定エラー
**原因**: `tsserver_path` に `nil` が設定されると設定が壊れる

**対策**: TypeScriptライブラリの検出とパス設定を条件分岐で処理（修正済み）

### 3. LSPクライアントの競合
**原因**: 複数のTypeScript LSP（ts_ls, vtsls, typescript-tools）が同時に起動しようとする

**対策**: 不要なLSPをスキップリストに追加（設定済み）

## 予防措置

### updatetime の調整
`updatetime` を適切な値に設定（デフォルト: 1000ms）
```lua
vim.o.updatetime = 1000
```

### 不要なLSPの無効化
使用しないLSP（例: terraformls）はスキップリストに追加：
```lua
local skip = {
  -- ...
  terraformls = true,  -- Terraform CLIが必要
}
```

### 大規模ファイルのタイムアウト調整
1MB以上のファイルでは自動的にタイムアウトを延長する設定が有効です。

## 環境確認コマンド（ターミナル）

### Node.jsとTypeScriptの確認
```bash
which node
node --version
which npx
npx tsc --version
```

### TypeScriptライブラリの場所確認
プロジェクトローカル：
```bash
ls -la node_modules/typescript/lib/tsserverlibrary.js
```

グローバル（Homebrew）：
```bash
ls -la /opt/homebrew/lib/node_modules/typescript/lib/tsserverlibrary.js
```

## トラブルシューティングフロー

1. **症状確認**: 何が動作していないか（補完、診断、ジャンプ等）
2. **`:LspInfo` / `:TSStatus`**: クライアントがアタッチされているか確認
3. **`:LspDebug`**: 詳細情報を確認
4. **`:TSRestart` / `:LspRestart`**: LSPを再起動
5. **LSPログ確認**: エラーメッセージを探す
6. **必要に応じて設定調整**: 本ドキュメントの対策を参照

## 関連ファイル

- LSP設定: `nvim/lua/plugins/lsp.lua`
- LSPログ: `~/.local/state/nvim/lsp.log` (通常)
- TypeScript設定: `nvim/lua/plugins/lsp.lua` 703-895行目付近

## 参考リンク

- [typescript-tools.nvim](https://github.com/pmizio/typescript-tools.nvim)
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- Neovim LSP公式ドキュメント: `:help lsp`
