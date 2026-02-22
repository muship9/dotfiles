# Claude Code Project Configuration

## プロジェクト概要
このリポジトリは個人用dotfilesで、macOS環境での開発環境セットアップを管理しています。主要コンポーネントはNeovim、Zsh、WezTerm、Starship等です。

## プロジェクト構造
```
dotfiles/
├── nvim/              # Neovim設定 (Lua + lazy.nvim)
│   ├── lua/config/    # 基本設定 (keymaps, options, autocmds)
│   └── lua/plugins/   # プラグイン設定 (LSP, formatting, UI等)
├── zsh/               # Zsh設定 (モジュール式)
│   ├── aliases.zsh    # エイリアス定義
│   ├── environment.zsh # 環境変数
│   └── mcp.zsh        # MCPサーバーセットアップ
├── wezterm/           # WezTermターミナル設定
├── starship/          # プロンプトカスタマイズ
├── git/               # Gitグローバル設定
├── ai/codex.md        # AIアシスタント用指示
├── skills/            # 実行可能な操作手順書
│   ├── lint-and-format.md    # lint/formatコマンド集
│   ├── plugin-management.md  # Neovimプラグイン管理
│   ├── deployment.md          # セットアップとデプロイ
│   └── debugging.md           # トラブルシューティング
├── docs/              # 詳細ドキュメント
│   └── lsp-troubleshooting.md
└── deploy.sh          # セットアップスクリプト
```

## 開発環境とツール

### 必須コマンド
- **Neovim**: v0.9以上
- **Node.js & npm**: LSPサーバー用
- **Homebrew**: macOSパッケージ管理
- **ripgrep (rg)**: 高速検索
- **fd**: ファイル検索

### Neovimプラグイン管理
- **パッケージマネージャー**: lazy.nvim
- **LSPサーバー管理**: Mason.nvim
- **フォーマッター**: conform.nvim (stylua, prettier等)
- **補完**: nvim-cmp + LuaSnip

## コーディング規約

詳細は `skills/coding-standards.md` を参照。
- Lua: snake_case、stylua フォーマッター
- Shell: `set -euo pipefail`、shellcheck 検証
- 命名規則とベストプラクティス

## コミット規約

`type(scope): summary` 形式。詳細は `skills/git-operations.md` を参照。

## プロジェクト特有の設定

- **MCPサーバー**: Atlassian、Kibela、Figma → `skills/mcp-setup.md`
- **言語環境**: Python、Node.js、Ruby、Go → `skills/language-environments.md`

## Skills Directory

実行可能な操作手順は `skills/` ディレクトリに整理：

| ファイル | 内容 |
|---------|------|
| `lint-and-format.md` | コード検証とフォーマット |
| `plugin-management.md` | Neovimプラグイン管理 |
| `deployment.md` | セットアップとデプロイ |
| `debugging.md` | トラブルシューティング |
| `coding-standards.md` | コーディング規約 |
| `git-operations.md` | Git操作とコミット規約 |
| `search-and-navigation.md` | 検索とナビゲーション |
| `mcp-setup.md` | MCPサーバー設定 |
| `language-environments.md` | 言語別環境設定 |

## Claude Code固有の指示
- 設定ファイル編集時は既存のスタイルを維持してください
- 新機能追加時は既存のパターンに従ってください
- コミット前に必ず `skills/lint-and-format.md` のコマンドでlint/formatを実行してください
- deploy.shの変更は慎重に行い、既存環境を破壊しないよう注意してください
- 日本語でのコミュニケーションを優先してください（`ai/codex.md`参照）
- 具体的な操作手順は `skills/` ディレクトリのドキュメントを参照してください

## GitHub開発ワークフロー
- 新規開発や修正は PR を作成すること
- PR は必ず draft で作成（`gh pr create --draft`）
- コミットは適切なコンテキストで行う（1コミット1目的）
- PR 説明は日本語で記述し、レビュワー観点で内容を構成
- リポジトリに `.github/pull_request_template.md` が存在する場合は必ずそれを使用
- PR ごとにテスト観点をまとめて記載