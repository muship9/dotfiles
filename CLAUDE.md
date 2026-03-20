# Claude Code Project Configuration

## プロジェクト概要
個人用dotfiles。macOS環境でのNeovim、Zsh、WezTerm、Starship等の開発環境を管理。

## プロジェクト構造
```
dotfiles/
├── nvim/              # Neovim設定 (Lua + lazy.nvim)
├── zsh/               # Zsh設定 (モジュール式)
├── wezterm/           # WezTerm設定
├── starship/          # プロンプト設定
├── git/               # Gitグローバル設定
├── ai/                # AIアシスタント用指示
├── .claude/skills/    # 操作手順書
└── deploy.sh          # セットアップスクリプト
```

## Skills Directory

具体的な操作手順は `.claude/skills/` を参照：

| ファイル | 内容 |
|---------|------|
| `coding-standards.md` | コーディング規約 |
| `debugging.md` | トラブルシューティング |
| `deployment.md` | セットアップとデプロイ |
| `git-operations.md` | Git操作とコミット規約 |
| `language-environments.md` | 言語別環境設定 |
| `lint-and-format.md` | コード検証とフォーマット |
| `mcp-setup.md` | MCPサーバー設定 |
| `plugin-management.md` | Neovimプラグイン管理 |
| `search-and-navigation.md` | 検索とナビゲーション |

## Claude Code固有の指示
- 設定ファイル編集時は既存のスタイルを維持する
- コミット前に `.claude/skills/lint-and-format.md` のコマンドでlint/formatを実行する
- deploy.sh の変更は慎重に行い、既存環境を破壊しないよう注意する
