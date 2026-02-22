# Git Operations

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
# 設定ファイル変更時
"feat(nvim): add telescope extension for file history"
"fix(zsh): resolve PATH duplication on macOS"
"refactor(skills): simplify git-operations for Claude Code"

# Claude設定変更時は必ずスコープを明示
"feat(claude): add WebFetch permission for documentation"
"docs(claude): add GitHub workflow guidelines"
```

## GitHub ワークフロー

### PR作成手順
```bash
# 1. ブランチ作成（命名規則に従う）
git switch -c feature/description  # 新機能
git switch -c fix/description       # バグ修正
git switch -c refactor/description  # リファクタリング

# 2. 変更をコミット（上記規約に従う）
git add -A
git commit -m "type(scope): clear description"

# 3. リモートにプッシュ
git push -u origin branch-name

# 4. PR作成（必ずdraftで開始）
gh pr create --draft \
  --title "type(scope): タイトル（日本語OK）" \
  --body "PR説明（日本語で記載）"

# 5. レビュー準備完了後
gh pr ready PR番号
```

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

### マージコンフリクト解決
```bash
# 最新のmainを取得してマージ
git fetch origin main
git merge origin/main

# コンフリクトファイルを確認・編集
git status  # コンフリクトファイル確認
# ファイルを編集して <<<<<<< ======= >>>>>>> を解決

# 解決後
git add 解決したファイル
git commit -m "Merge branch 'origin/main' into current-branch"
git push
```

### PR作成時のエラー
```bash
# draft状態の確認
gh pr view PR番号 --json isDraft,state

# CI失敗時はログ確認
gh pr checks PR番号

# PR一覧確認
gh pr list --author @me
```

## プロジェクト固有の注意事項

### 変更を避けるべきファイル
- `.claude/settings.local.json` - 自動生成される権限設定
- 生成されたファイルの末尾の改行に注意

### git/ignoreの管理
- 重複エントリを避ける
- 特に `**/.claude/settings.local.json` の重複に注意

### コミット時の確認事項
- 機密情報が含まれていないか
- lint/formatを実行したか（`skills/lint-and-format.md` 参照）
- 不要なデバッグコードが残っていないか