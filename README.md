# dotfiles

個人用ローカルセットアップ

## 必要なツール

### 必須
- **Neovim** (v0.9+)
- **Git**
- **Node.js** & **npm** (LSP servers用)
- **Homebrew** (macOS)

### 推奨
- **neovim-remote** (LazyGit連携用)
- **ripgrep** (高速検索用)
- **fd** (高速ファイル検索用)
- **starship** (プロンプトカスタマイズ)
- **LazyGit** (Git UI)

## インストール手順

### 1. 依存関係のインストール

```bash
# Homebrew (macOS)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 必須ツール
brew install neovim git node

# 推奨ツール
brew install ripgrep fd starship lazygit
pip3 install neovim-remote
```

### 2. dotfilesのクローンとセットアップ

```bash
# dotfilesをクローン
git clone <your-repo-url> ~/.dotfiles
cd ~/.dotfiles

# デプロイスクリプトを実行
chmod +x deploy.sh
./deploy.sh
```

### 3. シェル設定の反映

```bash
# zshrc設定を反映
source ~/.zshrc
```

## 含まれる設定

### Neovim (`nvim/`)
- **プラグイン管理**: lazy.nvim
- **LSP**: 各言語のLanguage Server Protocol対応
- **ファイル探索**: Neo-tree, Telescope, fzf-lua
- **Git連携**: LazyGit (neovim-remote使用)
- **自動補完**: nvim-cmp
- **シンタックスハイライト**: Treesitter

### 主要キーマッピング
- `<Space>` - Leader key
- `<leader>e` - Neo-tree toggle
- `<leader><leader>` - ファイル検索
- `<leader>/` - プロジェクト内検索
- `<leader>gg` - LazyGit
- `<leader>w` - バッファを閉じる
- `<leader>cp` - 相対パスをコピー
- `<leader>gb` - Git blame
- `<leader>gB` - GitHubで開く

### その他の設定
- **Starship**: カスタムプロンプト (`starship/`)
- **WezTerm**: ターミナル設定 (`wezterm/`)
- **Git**: グローバルignore設定 (`git/`)

## LazyGit連携

LazyGit内でファイルを編集する際、現在のNeovimインスタンスで開くように設定済み。

- LazyGit内で `e` キーを押すとNeovimの新しいタブでファイルが開く
- コミットメッセージもNeovim内で編集可能

## トラブルシューティング

### LazyGitでファイルが正しく開かない場合

1. neovim-remoteがインストールされているか確認
```bash
which nvr
```

2. Neovimのサーバー名が設定されているか確認
```vim
:echo v:servername
:echo $NVIM
```

3. 新しいシェルセッションを開いて設定を反映
```bash
source ~/.zshrc
```

### LSPが動作しない場合

```bash
# Neovim内で
:checkhealth
:Mason  # LSP serverの管理
```

## ファイル構成

```
dotfiles/
├── README.md          # このファイル
├── CLAUDE.md          # Claude Code用プロジェクト設定
├── deploy.sh          # デプロイスクリプト
├── nvim/              # Neovim設定
│   ├── init.lua
│   └── lua/
│       ├── config/    # 基本設定
│       └── plugins/   # プラグイン設定
├── starship/          # Starshipプロンプト設定
├── wezterm/           # WezTerm設定
└── git/               # Git設定
```

## 更新

```bash
cd ~/.dotfiles
git pull
./deploy.sh  # 必要に応じて
```
