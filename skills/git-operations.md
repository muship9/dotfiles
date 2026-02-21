# Git Operations

## 概要
Git操作のエイリアス、コミット規約、ブランチ管理方法。
効率的なバージョン管理とチーム開発のためのGitワークフロー。

## Gitエイリアス一覧

### 基本操作
```bash
# ステータス確認
gst  # git status

# ファイル追加
ga   # git add
ga . # 全ファイル追加

# コミット
gcm  # git commit -m

# 差分確認
gd   # git diff
```

### ブランチ操作
```bash
# ブランチ一覧
gb   # git branch

# ブランチ切り替え
gsw  # git switch
gswc # git switch -c (新規作成して切り替え)
gswm # git switch main (mainブランチへ)

# 変更を破棄
gch  # git checkout . (全ファイルの変更を破棄)
```

### リモート操作
```bash
# プル
gp   # git pull origin $(git branch --show-current)

# プッシュ
gpu  # git push origin $(git branch --show-current)

# フェッチ
gf   # git fetch

# マージ
gm   # git merge
```

## コミット規約

### 基本形式
```
type(scope): summary

詳細な説明（任意）

関連Issue: #123（任意）
```

### Type一覧
- **feat**: 新機能追加
- **fix**: バグ修正
- **docs**: ドキュメント変更
- **style**: コードスタイル変更（機能に影響なし）
- **refactor**: リファクタリング
- **test**: テスト追加・修正
- **chore**: ビルドプロセスや補助ツールの変更

### Scope一覧（このプロジェクト用）
- **nvim**: Neovim設定
- **zsh**: Zsh設定
- **wezterm**: WezTerm設定
- **starship**: Starshipプロンプト
- **git**: Git設定
- **docs**: ドキュメント
- **skills**: スキルドキュメント

### コミット例
```bash
# 新機能
git commit -m "feat(nvim): add new telescope extension for file history"

# バグ修正
git commit -m "fix(zsh): resolve PATH duplication issue on macOS"

# ドキュメント
git commit -m "docs(skills): add debugging guide for common issues"

# リファクタリング
git commit -m "refactor(nvim): simplify plugin loading logic"

# 設定変更
git commit -m "chore: update gitignore for local env files"
```

## ブランチ戦略

### ブランチ命名規則
```bash
# 機能追加
feature/description-of-feature

# バグ修正
fix/description-of-fix

# ドキュメント
docs/description-of-docs

# 実験的変更
experimental/description
```

### ワークフロー例
```bash
# 1. 新機能の開発開始
git switch -c feature/add-new-plugin

# 2. 作業とコミット
git add .
git commit -m "feat(nvim): add new plugin configuration"

# 3. リモートへプッシュ
git push origin feature/add-new-plugin

# 4. mainブランチへマージ（PR後）
git switch main
git pull origin main
git merge feature/add-new-plugin

# 5. ブランチの削除
git branch -d feature/add-new-plugin
git push origin --delete feature/add-new-plugin
```

## 便利なGitコマンド

### ログ確認
```bash
# 簡潔なログ表示
git log --oneline -10

# グラフ表示
git log --graph --oneline --all

# 特定ファイルの履歴
git log --follow path/to/file
```

### 変更の取り消し
```bash
# 直前のコミットを修正
git commit --amend

# 特定のコミットまで戻る（履歴は残る）
git revert <commit-hash>

# 特定のコミットまで戻る（履歴も消える）
git reset --hard <commit-hash>  # 注意：データが失われる

# ステージングを取り消し
git reset HEAD <file>
```

### stash操作
```bash
# 一時保存
git stash
git stash save "作業内容の説明"

# 一覧表示
git stash list

# 復元
git stash pop   # 最新を復元して削除
git stash apply # 最新を復元（削除しない）

# 削除
git stash drop
git stash clear # 全て削除
```

## Gitグローバル設定

### 基本設定
```bash
# ユーザー情報
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# エディター設定
git config --global core.editor "nvim"

# グローバルignore
git config --global core.excludesFile "$HOME/.config/git/ignore"
```

### エイリアス設定（グローバル）
```bash
# よく使うコマンドのエイリアス
git config --global alias.st "status"
git config --global alias.co "checkout"
git config --global alias.br "branch"
git config --global alias.cm "commit -m"
git config --global alias.last "log -1 HEAD"
```

## トラブルシューティング

### マージコンフリクト
```bash
# 1. コンフリクトファイルを確認
git status

# 2. ファイルを編集してコンフリクトを解決
nvim <conflicted-file>

# 3. 解決後、ステージング
git add <resolved-file>

# 4. コミット
git commit
```

### リモートとの同期問題
```bash
# リモートの状態を確認
git remote -v
git fetch --all

# ローカルをリモートに強制的に合わせる
git reset --hard origin/main

# リモートをローカルに強制的に合わせる（危険）
git push --force origin main
```

### 間違えてコミットした場合
```bash
# 直前のコミットを取り消し（ファイルは残る）
git reset --soft HEAD~1

# 直前のコミットを完全に取り消し（ファイルも戻る）
git reset --hard HEAD~1
```

## ベストプラクティス

### コミット前の確認
```bash
# 必ず差分を確認
git diff
git diff --staged  # ステージング済みの差分

# ステータスを確認
git status
```

### きれいな履歴を保つ
- 1コミット1機能を心がける
- WIPコミットは後でsquashする
- 意味のあるコミットメッセージを書く
- プッシュ前にログを確認する

### セキュリティ
- 秘密情報をコミットしない
- `.gitignore`を適切に設定
- 間違えてコミットした場合は履歴から完全に削除