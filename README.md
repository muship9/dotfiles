# dotfiles

個人用開発環境セットアップ（macOS対応）

## 必要なツール

### 必須
- **Neovim** (v0.9+)
- **Git**
- **Node.js** & **npm** (LSP servers用)
- **Homebrew** (macOS)

### 推奨
- **ripgrep** (高速検索用)
- **fd** (高速ファイル検索用)
- **starship** (プロンプトカスタマイズ)
- **WezTerm** (ターミナルエミュレータ)
- **direnv** (環境変数管理)
- **yazi** (ターミナルファイルマネージャ)
- **k9s** (Kubernetes TUI)
- **mycli** (MySQL CLI)

## インストール手順

### 1. 依存関係のインストール

```bash
# Homebrew (macOS)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 必須ツール
brew install neovim git node

# 推奨ツール
brew install ripgrep fd starship direnv yazi k9s mycli
brew install --cask wezterm
```

### 2. dotfilesのクローンとセットアップ

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles

chmod +x deploy.sh
./deploy.sh
```

`deploy.sh` は以下を行います:
- Zsh plugins のインストール (`zsh-autosuggestions`, `zsh-syntax-highlighting`)
- `~/.zshrc`, `~/.config/nvim`, `~/.config/wezterm`, `~/.config/starship.toml`, `~/.config/git/ignore` のシンボリックリンク作成

### 3. シェル設定の反映

```bash
source ~/.zshrc
```

### 4. Gitのグローバルignore設定（任意）

```bash
git config --global core.excludesFile "$HOME/.config/git/ignore"
```

## 含まれる設定

### Neovim (`nvim/`)
- **プラグイン管理**: lazy.nvim
- **LSP**: Mason.nvim + 各言語のLanguage Server
- **ファイル探索**: Neo-tree, Telescope
- **自動補完**: nvim-cmp + LuaSnip
- **シンタックスハイライト**: Treesitter
- **フォーマット**: conform.nvim (stylua, prettier等)
- **AI補完**: Copilot.lua, claude-code.nvim
- **Git統合**: gitsigns.nvim (hunk操作), diffview.nvim (diff/履歴ビューア), octo.nvim (GitHub PR/Issues)
- **Markdown**: render-markdown.nvim
- **TODO管理**: todo-comments.nvim

### Zsh (`zsh/`)
モジュール式構成。`.zshrc` から各ファイルを source する形式。

| ファイル | 内容 |
|---------|------|
| `aliases.zsh` | コマンドエイリアス |
| `editor.zsh` | エディター設定 |
| `environment.zsh` | 環境変数 |
| `functions.zsh` | カスタム関数 |
| `kube-ps1.zsh` | Kubernetesコンテキスト表示 |
| `language-managers.zsh` | 言語バージョン管理 (mise等) |
| `mcp.zsh` | MCPサーバー設定 |
| `paths.zsh` | PATH設定 |
| `shell-enhancements.zsh` | シェル補完・ハイライト等 |

### その他
- **Starship** (`starship/`): カスタムプロンプト（Kubernetes, Git, 言語バージョン表示）
- **WezTerm** (`wezterm/`): ターミナル設定（vimライクなコピーモード対応）
- **Git** (`git/`): グローバルignore設定
- **mycli** (`mycli/`): MySQL CLI設定（prod/dev/local/base プロファイル）

## ファイル構成

```
dotfiles/
├── README.md
├── CLAUDE.md          # Claude Code用プロジェクト設定
├── deploy.sh          # セットアップスクリプト
├── nvim/              # Neovim設定
│   ├── init.lua
│   └── lua/
│       ├── config/    # 基本設定（keymaps, options, autocmds）
│       └── plugins/   # プラグイン設定
├── zsh/               # Zsh設定（モジュール式）
├── wezterm/           # WezTerm設定
├── starship/          # Starshipプロンプト設定
├── git/               # Gitグローバルignore
├── mycli/             # mycli設定（prod/dev/local）
├── docs/              # 詳細ドキュメント
└── .claude/           # Claude Code設定
```

## トラブルシューティング

### LSPが動作しない場合

```bash
# Neovim内で
:checkhealth
:Mason  # LSP serverの管理
```

詳細は `docs/lsp-troubleshooting.md` を参照。

## 更新

```bash
cd ~/dotfiles
git pull
./deploy.sh  # 必要に応じて
```
