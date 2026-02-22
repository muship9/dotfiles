# Git Operations

## このプロジェクトのエイリアス

```bash
# 基本操作
gst  → git status
ga   → git add
gcm  → git commit -m
gd   → git diff

# ブランチ操作  
gsw  → git switch
gswc → git switch -c (新規作成)
gswm → git switch main
gb   → git branch

# リモート操作
gpu  → git push origin $(git branch --show-current)
gp   → git pull origin $(git branch --show-current)
gf   → git fetch
```

## コミット規約

形式: `type(scope): summary`

### type
- **feat**: 新機能追加
- **fix**: バグ修正
- **docs**: ドキュメント変更
- **style**: コードスタイル（機能に影響なし）
- **refactor**: リファクタリング
- **test**: テスト追加・修正
- **chore**: ビルド・ツール変更

### scope (このプロジェクト用)
- **nvim**: Neovim設定
- **zsh**: Zsh設定
- **wezterm**: WezTerm設定
- **starship**: Starshipプロンプト
- **git**: Git設定
- **claude**: Claude Code設定

### 例
```bash
git commit -m "feat(nvim): add telescope extension"
git commit -m "fix(zsh): resolve PATH duplication"
git commit -m "docs(skills): add debugging guide"
```

## ブランチ命名

- `feature/description` - 機能追加
- `fix/description` - バグ修正
- `docs/description` - ドキュメント
- `refactor/description` - リファクタリング

## よく使うコマンド

### ログ確認
```bash
git log --oneline -10           # 簡潔表示
git log --graph --oneline --all # グラフ表示
```

### 変更の取り消し
```bash
git commit --amend              # 直前のコミット修正
git reset --soft HEAD~1         # コミット取り消し（ファイル残る）
git reset --hard HEAD~1         # 完全に取り消し（注意）
```

### stash
```bash
git stash                       # 一時保存
git stash pop                   # 復元して削除
git stash list                  # 一覧
```

## マージコンフリクト解決

1. `git status` でコンフリクトファイル確認
2. ファイルを編集して解決
3. `git add <file>` でステージング
4. `git commit` で完了

## ベストプラクティス

- 1コミット1機能
- 意味のあるコミットメッセージ
- プッシュ前に `git diff` と `git status` で確認
- 秘密情報をコミットしない
- `.gitignore` を適切に設定