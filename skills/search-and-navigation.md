# Search & Navigation

## 概要
ファイル検索、コード検索、ディレクトリナビゲーションの効率的な方法。
ripgrep、fd、Telescope、fzf-luaを活用した高速検索テクニック。

## ripgrep (rg) - コンテンツ検索

### 基本的な使い方
```bash
# 基本検索
rg "検索文字列"

# ファイルタイプ指定
rg "function" --type lua
rg "TODO" --type sh

# ディレクトリ指定
rg "pattern" path/to/dir

# 大文字小文字無視
rg -i "pattern"
```

### 高度な検索
```bash
# 正規表現
rg "func\w+"
rg "^class\s+\w+"

# ファイル名のみ表示
rg -l "pattern"

# マッチしないファイルを表示
rg -L "pattern"

# コンテキスト表示（前後の行）
rg -C 3 "pattern"  # 前後3行
rg -B 2 "pattern"  # 前2行
rg -A 2 "pattern"  # 後2行

# 除外パターン
rg "pattern" --glob "!*.min.js"
rg "pattern" --glob "!node_modules/**"
```

### プロジェクト内検索のベストプラクティス
```bash
# dotfiles内でLua設定を検索
rg "keymaps" --type lua nvim/

# TODO/FIXMEコメントを探す
rg "TODO|FIXME" --type-add 'config:*.{lua,zsh,sh}'

# 関数定義を探す
rg "^function\s+\w+|^\w+\s*=\s*function" --type lua
```

## fd - ファイル/ディレクトリ検索

### 基本的な使い方
```bash
# ファイル名検索
fd "pattern"

# 拡張子指定
fd -e lua
fd -e md -e txt

# ディレクトリのみ
fd -t d

# ファイルのみ
fd -t f

# シンボリックリンク
fd -t l
```

### 高度な検索
```bash
# 正規表現
fd ".*\.lua$"

# 大文字小文字無視
fd -i "readme"

# 隠しファイルも含む
fd -H ".gitignore"

# 深さ制限
fd --max-depth 2 "pattern"

# 除外パターン
fd -E node_modules -E .git "pattern"
```

### 便利な使用例
```bash
# Neovim設定ファイルを探す
fd -e lua . nvim/

# 最近変更されたファイル
fd -t f --changed-within 1d  # 1日以内
fd -t f --changed-within 1w  # 1週間以内

# サイズで絞り込み
fd --size +1M  # 1MB以上
fd --size -100k  # 100KB以下
```

## Neovim内検索 (Telescope)

### ファイル検索
```vim
" キーマップ（設定済み）
<leader><leader>  " ファイル検索
<leader>fr        " 最近開いたファイル
<leader>fb        " バッファ一覧
```

### grep検索
```vim
" キーマップ（設定済み）
<leader>/         " プロジェクト内grep
<leader>sg        " grep検索（詳細）
<leader>sw        " カーソル下の単語を検索
```

### その他の検索
```vim
" キーマップ（設定済み）
<leader>sh        " ヘルプタグ検索
<leader>sk        " キーマップ検索
<leader>sc        " コマンド履歴
<leader>sd        " 診断情報（エラー/警告）
```

### Telescope操作
```vim
" 検索窓内での操作
<C-j/k>   " 選択移動
<CR>      " 開く
<C-x>     " 水平分割で開く
<C-v>     " 垂直分割で開く
<C-t>     " タブで開く
<C-u/d>   " プレビューをスクロール
<Esc>     " 閉じる
```

## fzf-lua (代替検索)

### 基本操作
```vim
" キーマップ例
:FzfLua files          " ファイル検索
:FzfLua grep_project   " プロジェクト内grep
:FzfLua buffers        " バッファ一覧
:FzfLua oldfiles       " 履歴ファイル
```

### 高度な検索
```vim
" LSP関連
:FzfLua lsp_references        " 参照検索
:FzfLua lsp_definitions       " 定義へジャンプ
:FzfLua lsp_implementations   " 実装へジャンプ
:FzfLua lsp_document_symbols  " ドキュメントシンボル

" Git関連
:FzfLua git_files     " Gitファイル
:FzfLua git_status    " Git status
:FzfLua git_commits   " コミット履歴
:FzfLua git_branches  " ブランチ一覧
```

## ディレクトリナビゲーション

### 基本的な移動
```bash
# エイリアス（設定済み）
..    # cd ..
...   # cd ../..
....  # cd ../../..

# 直前のディレクトリ
cd -

# ホームディレクトリ
cd ~
cd    # 引数なしでもホームへ
```

### zsh固有の機能
```bash
# ディレクトリスタック
pushd /path/to/dir  # スタックに追加して移動
popd                 # スタックから取り出して移動
dirs                 # スタック表示

# 履歴から検索
cd <Tab><Tab>  # 補完候補表示

# パス省略
cd /u/l/b  # /usr/local/bin に展開（Tab補完）
```

### autojump/z系ツール（インストールが必要）
```bash
# zoxide (推奨)
brew install zoxide

# 設定後の使い方
z pattern     # 頻度の高いディレクトリへジャンプ
zi pattern    # インタラクティブ選択
```

## Neo-treeナビゲーション

### 基本操作
```vim
" トグル
<leader>e  " Neo-tree toggle

" Neo-tree内での操作
j/k        " 上下移動
h/l        " ディレクトリ開閉
<CR>       " ファイル/ディレクトリを開く
a          " 新規作成
d          " 削除
r          " リネーム
y          " コピー
x          " カット
p          " ペースト
```

## 検索のコンビネーション技

### パイプラインで組み合わせ
```bash
# fdで見つけたファイルの中身をrgで検索
fd -e lua | xargs rg "keymaps"

# 特定ディレクトリ内のTODOを探す
fd -t f . nvim/ | xargs rg "TODO"

# 最近変更されたファイルから検索
fd --changed-within 1w -e lua | xargs rg "config"
```

### Neovimとの連携
```bash
# 検索結果をNeovimで開く
rg -l "pattern" | xargs nvim

# fzfと組み合わせて選択的に開く
rg -l "pattern" | fzf | xargs nvim
```

## パフォーマンス最適化

### .rgignore / .fdignore
```bash
# プロジェクトルートに配置
echo "node_modules/" > .rgignore
echo ".git/" >> .rgignore
echo "*.min.js" >> .rgignore
```

### 検索を高速化するコツ
1. 検索範囲を限定する（ディレクトリ指定）
2. ファイルタイプを指定する（--type）
3. 不要なディレクトリを除外する（--glob）
4. 正規表現は必要な時のみ使用
5. `.rgignore`で恒久的に除外設定