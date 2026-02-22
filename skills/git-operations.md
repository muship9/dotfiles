# Git Operations

## Worktree運用（推奨）

### 基本概念
一つのリポジトリから複数の作業ディレクトリを作成し、並行作業を可能にする。

```
~/dotfiles/              # メインディレクトリ（通常main）
~/dotfiles-feat-xyz/     # 新機能開発用
~/dotfiles-fix-abc/      # バグ修正用
~/dotfiles-pr-14/        # PR #14 レビュー用
```

### 基本的な作業フロー

#### 新規作業の開始
```bash
# メインディレクトリから新しいworktreeを作成
cd ~/dotfiles
git worktree add ../dotfiles-feat-telescope -b feature/telescope-config

# 作成したディレクトリで作業
cd ../dotfiles-feat-telescope
# ここで通常通り編集・コミット
```

#### PR作成まで
```bash
# worktree内で作業・コミット
git add -A
git commit -m "feat(nvim): add telescope configuration"

# リモートにプッシュ
git push -u origin feature/telescope-config

# PR作成（worktree内から実行可能）
gh pr create --draft --title "feat(nvim): Telescope設定追加"
```

#### 作業完了後のクリーンアップ
```bash
# メインディレクトリに戻る
cd ~/dotfiles

# worktreeを削除
git worktree remove ../dotfiles-feat-telescope

# マージ済みブランチを削除
git branch -d feature/telescope-config
```

### 並行作業のシナリオ

#### 緊急バグ修正が入った場合
```bash
# 現在feature開発中でも、新しいworktreeで対応
git worktree add ../dotfiles-hotfix -b fix/urgent-bug

cd ../dotfiles-hotfix
# 修正作業
git add -A && git commit -m "fix(zsh): urgent path issue"
git push -u origin fix/urgent-bug
gh pr create --title "fix(zsh): 緊急パス問題修正"

# 元の作業に戻る（stashやcommit不要）
cd ../dotfiles-feat-xyz
```

#### 複数PRのレビュー
```bash
# PR #14をレビュー
git worktree add ../dotfiles-pr-14 pr-14-branch
cd ../dotfiles-pr-14
# 実際に動作確認

# 同時にPR #15もレビュー
git worktree add ../dotfiles-pr-15 pr-15-branch
cd ../dotfiles-pr-15
```

### Worktree管理コマンド

```bash
# worktree一覧表示
git worktree list

# 不要になったworktreeを削除
git worktree remove ../dotfiles-feat-xyz

# 削除済みworktreeの参照をクリーンアップ
git worktree prune
```

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

## GitHub ワークフロー（Worktree活用）

### PR作成の流れ
1. **worktree作成**: `git worktree add ../dotfiles-pr-desc -b branch-name`
2. **作業実施**: worktree内で編集・テスト
3. **コミット**: 規約に従ってコミット
4. **PR作成**: `gh pr create --draft`（必ずdraftから）
5. **レビュー準備**: `gh pr ready PR番号`
6. **マージ後**: `git worktree remove ../dotfiles-pr-desc`

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

## トラブルシューティング

### Worktree関連

#### "fatal: 'branch' is already checked out at..."
```bash
# 既に他のworktreeで使用中のブランチ
git worktree list  # 確認
# 別の名前でworktreeを作成するか、既存を削除
```

#### worktreeディレクトリが見つからない
```bash
# 手動削除した場合の対処
git worktree prune  # 参照をクリーンアップ
```

### マージコンフリクト（worktree内で解決）
```bash
# worktree内で最新mainを取り込み
git fetch origin main
git merge origin/main

# コンフリクト解決後
git add 解決したファイル
git commit -m "Merge branch 'origin/main' into current-branch"
git push
```

## プロジェクト固有の注意事項

### Worktree命名規則
- `dotfiles-feat-*`: 新機能開発
- `dotfiles-fix-*`: バグ修正
- `dotfiles-pr-*`: PRレビュー用
- `dotfiles-hotfix`: 緊急修正用

### 変更を避けるべきファイル
- `.claude/settings.local.json` - 自動生成される権限設定
- 各worktreeでの設定は独立している点に注意

### コミット時の確認事項
- 機密情報が含まれていないか
- lint/formatを実行したか（`skills/lint-and-format.md` 参照）
- 正しいworktreeで作業しているか（`pwd` で確認）