# dotfiles

個人用開発環境セットアップ（macOS対応）

## 必要なツール

### 必須
- **Neovim** (v0.9+)
- **Git**
- **Node.js** & **npm** (LSP servers用)
- **Homebrew** (macOS)
- **Obsidian** (ノート管理)

### 推奨
- **neovim-remote** (LazyGit連携用)
- **ripgrep** (高速検索用)
- **fd** (高速ファイル検索用)
- **starship** (プロンプトカスタマイズ)
- **LazyGit** (Git UI)
- **WezTerm** (ターミナルエミュレータ)

## インストール手順

### 1. 依存関係のインストール

```bash
# Homebrew (macOS)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 必須ツール
brew install neovim git node

# 推奨ツール
brew install ripgrep fd starship lazygit wezterm
pip3 install neovim-remote

# Obsidianを手動でインストール
# https://obsidian.md/
```

### 2. dotfilesのクローンとセットアップ

```bash
# dotfilesをクローン（例: ~/dotfiles 配下）
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles

# デプロイスクリプトを実行
chmod +x deploy.sh
./deploy.sh
```

### 3. シェル設定の反映

```bash
# zshrc設定を反映
source ~/.zshrc
```

### 4. Gitのグローバルignore設定（任意）

```bash
git config --global core.excludesFile "$HOME/.config/git/ignore"
```

## 含まれる設定

### Neovim (`nvim/`)
- **プラグイン管理**: lazy.nvim
- **LSP**: 各言語のLanguage Server Protocol対応
- **ファイル探索**: Neo-tree, Telescope, fzf-lua
- **Git連携**: LazyGit (neovim-remote使用)
- **自動補完**: nvim-cmp
- **シンタックスハイライト**: Treesitter
- **Obsidian連携**: obsidian.nvim (Markdownノート管理)

### 主要キーマッピング

#### 基本操作
- `<Space>` - Leader key
- `<leader>e` - Neo-tree toggle
- `<leader><leader>` - ファイル検索
- `<leader>/` - プロジェクト内検索
- `<leader>gg` - LazyGit
- `<leader>w` - バッファを閉じる
- `<leader>cp` - 相対パスをコピー

#### Git関連
- `<leader>gb` - Git blame
- `<leader>gB` - GitHubで開く

#### Obsidian関連
- `<leader>on` - 新規ノート作成
- `<leader>oo` - Obsidianアプリを開く/アクティブ化
- `<leader>os` - ノート検索
- `<leader>oq` - クイックスイッチ
- `<leader>od` - 今日のデイリーノート
- `<leader>oy` - 昨日のデイリーノート
- `<leader>ot` - テンプレート挿入
- `<leader>ob` - バックリンク表示
- `<leader>ol` - リンク表示
- `<leader>ow` - ワークスペース切替
- `<leader>oa` - Obsidianアプリをアクティブ化
- `<leader>oby` - 選択範囲/現在行をデイリーノートにコピー

### その他の設定
- **Starship**: カスタムプロンプト (`starship/`)
- **WezTerm**: ターミナル設定 (`wezterm/`)
- **Git**: グローバルignore設定 (`git/`)
- **Zsh**: エイリアス設定とシェル環境 (`zsh/`)

### カスタムエイリアス
- `obs` - Obsidian Vaultに移動してNeovimを開く
- `obd` - 今日のデイリーノートを直接開く
- `gd` - git diff
- `gst` - git status
- `ga` - git add
- `gc` - git commit -m
- `gp` - git pull origin (現在のブランチ)
- `gpu` - git push origin (現在のブランチ)
- `gs` - git switch

## Obsidian連携

ターミナルからObsidianのノートを効率的に操作できるように設定済み。

### セットアップ
1. Obsidianアプリをインストール
2. `~/Documents/Obsidian Vault` にVaultを作成
3. 設定は自動で適用される

### 機能
- Neovim内からObsidianのノート管理
- デイリーノートの自動作成・編集
- 選択したコードやテキストのデイリーノートへの追加
- Obsidianアプリとの連携

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
├── deploy.sh          # デプロイスクリプト（~/.zshrc, ~/.config/* へリンク）
├── nvim/              # Neovim設定
│   ├── init.lua
│   └── lua/
│       ├── config/    # 基本設定（keymaps, options, autocmds）
│       └── plugins/   # プラグイン設定（obsidian, lsp, ui等）
├── zsh/               # Zsh設定
│   ├── aliases.zsh    # カスタムエイリアス
│   ├── editor.zsh     # エディター設定
│   ├── environment.zsh # 環境変数
│   └── ...
├── starship/          # Starshipプロンプト設定
├── wezterm/           # WezTerm設定
└── git/               # Git設定（global ignore）
```

## 更新

```bash
cd ~/dotfiles
git pull
./deploy.sh  # 必要に応じて
```
