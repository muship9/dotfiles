# Git Operations

## Worktree運用（推奨）

### 運用方針
メインディレクトリは常にmainブランチを保持し、各作業は別ディレクトリで並行実施する。

```
~/dotfiles/              # メインディレクトリ（常にmain）
~/dotfiles-feat-xyz/     # 新機能開発用
~/dotfiles-fix-abc/      # バグ修正用
~/dotfiles-pr-14/        # PR #14 レビュー用
```

### 命名規則
- `dotfiles-feat-*`: 新機能開発
- `dotfiles-fix-*`: バグ修正
- `dotfiles-pr-*`: PRレビュー用
- `dotfiles-hotfix`: 緊急修正用

### 活用シナリオ

#### 緊急バグ修正
feature開発中でも、新しいworktreeで即座に対応。stashやcommit不要。

#### 複数PRの並行レビュー
PR #14とPR #15を同時にレビューする場合、それぞれ別ディレクトリで動作確認。

#### コンテキストスイッチ
作業中のコードを一切触らずに、別タスクへ即座に切り替え可能。

## コミット規約

形式: `type(scope): summary`

### type定義
- **feat**: 新機能追加
- **fix**: バグ修正
- **docs**: ドキュメント変更
- **style**: コードスタイル（機能に影響なし）
- **refactor**: リファクタリング
- **test**: テスト追加・修正
- **chore**: ビルド・ツール変更

### scope定義（このプロジェクト固有）
- **nvim**: Neovim設定
- **zsh**: Zsh設定
- **wezterm**: WezTerm設定
- **starship**: Starshipプロンプト
- **git**: Git設定
- **claude**: Claude Code設定
- **skills**: skillsドキュメント

### コミットメッセージ例
```bash
"feat(nvim): add telescope extension for file history"
"fix(zsh): resolve PATH duplication on macOS"
"refactor(skills): optimize git-operations for Claude Code"
"docs(claude): add GitHub workflow guidelines"
```

## GitHub ワークフロー

### PR作成フロー（Worktree前提）
1. **worktree作成**: 専用ディレクトリで作業開始
2. **作業実施**: 編集・テスト・コミット
3. **PR作成**: `gh pr create --draft`（必ずdraftから）
4. **レビュー準備**: `gh pr ready PR番号`
5. **マージ後**: worktreeディレクトリを削除

### PR説明テンプレート
```markdown
## 概要
[変更の概要を1-2文で]

## 変更内容
- 変更点1
- 変更点2

## テスト観点
- [ ] テスト項目1
- [ ] テスト項目2
```

### GitHub CLI活用
```bash
# PR状態確認
gh pr view PR番号 --json isDraft,state

# CI確認
gh pr checks PR番号

# 自分のPR一覧
gh pr list --author @me
```

## トラブルシューティング

### Worktree関連

#### ブランチが既に使用中
他のworktreeで使用中のブランチは使えない。`git worktree list`で確認。

#### worktreeディレクトリが見つからない
手動削除した場合は`git worktree prune`で参照をクリーンアップ。

### マージコンフリクト解決
```bash
# worktree内で最新mainを取り込み
git fetch origin main
git merge origin/main

# コンフリクトファイルを編集して解決
# <<<<<<< ======= >>>>>>> マーカーを削除

# 解決後
git add 解決したファイル
git commit -m "Merge branch 'origin/main' into current-branch"
git push
```

## プロジェクト固有の注意事項

### 変更を避けるべきファイル
- `.claude/settings.local.json` - 自動生成される権限設定
- 各worktreeでの設定は独立している

### git/ignoreの管理
- 重複エントリを避ける
- 特に `**/.claude/settings.local.json` の重複に注意

### コミット前チェックリスト
- [ ] 機密情報が含まれていないか
- [ ] lint/formatを実行したか（`skills/lint-and-format.md` 参照）
- [ ] 正しいworktreeで作業しているか（`pwd` で確認）
- [ ] コミットメッセージは規約に従っているか