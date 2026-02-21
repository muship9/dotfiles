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

## インストール手順

### 1. 依存関係のインストール

```bash
# Homebrew (macOS)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 必須ツール
brew install neovim git node

# 推奨ツール
brew install ripgrep fd starship wezterm direnv

# nbツール（コマンドラインノート管理）
brew install xwmx/taps/nb
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
- **LSP**: Mason.nvim + 各言語のLanguage Server
- **ファイル探索**: Neo-tree, Telescope, fzf-lua
- **自動補完**: nvim-cmp + LuaSnip
- **シンタックスハイライト**: Treesitter
- **フォーマット**: conform.nvim (stylua, prettier等)
- **AI補完**: Copilot.lua
- **Markdown**: render-markdown.nvim
- **TODO管理**: todo-comments.nvim

### 主要キーマッピング

#### 基本操作
- `<Space>` - Leader key
- `<leader>e` - Neo-tree toggle
- `<leader><leader>` - ファイル検索
- `<leader>/` - プロジェクト内検索
- `<leader>w` - バッファを閉じる
- `<leader>cp` - 相対パスをコピー

#### Git関連
- `<leader>gb` - Git blame
- `<leader>gB` - GitHubで開く


### その他の設定
- **Starship**: カスタムプロンプト (`starship/`)
- **WezTerm**: ターミナル設定（vimライクなコピーモード対応） (`wezterm/`)
- **direnv**: 環境変数管理（重複読み込み防止対応）
- **Git**: グローバルignore設定 (`git/`)
- **Zsh**: エイリアス設定とシェル環境 (`zsh/`)

### カスタムエイリアス

#### ナビゲーション
- `cdot` - dotfilesディレクトリへ移動
- `cw` - workspaceへ移動
- `root` - Gitリポジトリのルートへ移動

#### nb関連（ノート管理）
- `nad` - 今日のデイリーノート作成
- `nat` - タスクノート作成
- `naw <filename>` - workディレクトリに新規ファイル作成

#### Git関連
- `gst` - git status
- `gd` - git diff
- `ga` - git add
- `gcm` - git commit -m
- `gp` - git pull origin (現在のブランチ)
- `gpu` - git push origin (現在のブランチ)
- `gsw` - git switch
- `gswc` - git switch -c (新規ブランチ作成)
- `gswm` - git switch main


## Skills Directory

実行可能な操作手順を整理したドキュメント集。具体的な作業を行う際の参照用。

| ファイル | 内容 |
|---------|------|
| `coding-standards.md` | コーディング規約とベストプラクティス |
| `debugging.md` | トラブルシューティング手順 |
| `deployment.md` | セットアップとデプロイ手順 |
| `git-operations.md` | Git操作とコミット規約 |
| `language-environments.md` | 言語別開発環境設定 |
| `lint-and-format.md` | コード検証とフォーマット |
| `mcp-setup.md` | MCPサーバー設定（Atlassian, Kibela, Figma） |
| `plugin-management.md` | Neovimプラグイン管理 |
| `search-and-navigation.md` | 検索とファイルナビゲーション |

## Claude連携

### プロジェクト設定
- `CLAUDE.md` - このリポジトリ専用のClaude Code設定
- `claude/global.md` - 全プロジェクト共通のグローバル設定

### MCPサーバー統合
Model Context Protocol (MCP) を使用した外部サービス連携:
- Atlassian (JIRA)
- Kibela (ドキュメント管理)
- Figma (デザインツール)

詳細は `skills/mcp-setup.md` を参照。

## トラブルシューティング

### LSPが動作しない場合

```bash
# Neovim内で
:checkhealth
:Mason  # LSP serverの管理
```

詳細なトラブルシューティングは `skills/debugging.md` を参照。

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
│       └── plugins/   # プラグイン設定（lsp, formatting, ui等）
├── zsh/               # Zsh設定（モジュール式）
│   ├── aliases.zsh    # カスタムエイリアス
│   ├── editor.zsh     # エディター設定
│   ├── environment.zsh # 環境変数
│   ├── mcp.zsh        # MCPサーバー設定
│   └── ...
├── skills/            # 実行可能な操作手順書
│   ├── coding-standards.md
│   ├── debugging.md
│   ├── deployment.md
│   ├── git-operations.md
│   ├── language-environments.md
│   ├── lint-and-format.md
│   ├── mcp-setup.md
│   ├── plugin-management.md
│   └── search-and-navigation.md
├── claude/            # Claude グローバル設定
│   └── global.md      # 全プロジェクト共通の指示
├── docs/              # 詳細ドキュメント
│   └── lsp-troubleshooting.md
├── mycli/             # CLIツール
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
