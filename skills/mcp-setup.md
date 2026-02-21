# MCP Setup

## 概要
Model Context Protocol (MCP)サーバーのセットアップと管理。
Atlassian (JIRA)、Kibela、Figmaなど外部サービスとの連携設定。

## 初回セットアップ

### 1. 環境変数ファイルの準備
```bash
# シークレットディレクトリ作成
mkdir -p ~/.secrets

# 環境変数ファイル作成
cat > ~/.secrets/claude-mcp.env << 'EOF'
# JIRA設定
export JIRA_URL="https://your-company.atlassian.net"
export JIRA_USERNAME="your.email@company.com"
export JIRA_API_TOKEN="your-jira-api-token"

# Kibela設定
export KIBELA_ORIGIN="https://your-team.kibe.la"
export KIBELA_ACCESS_TOKEN="your-kibela-access-token"
EOF

# 権限設定（重要）
chmod 600 ~/.secrets/claude-mcp.env
```

### 2. 環境変数の読み込み
```bash
# .zshrcに追加（既に設定済みの場合はスキップ）
echo 'source ~/.secrets/claude-mcp.env' >> ~/.zshrc

# 即座に反映
source ~/.secrets/claude-mcp.env
```

### 3. MCPサーバーの登録
```bash
# セットアップスクリプトを実行
source ~/dotfiles/zsh/mcp.zsh
```

## MCPサーバー詳細

### Atlassian (JIRA) MCP
**用途**: JIRAチケットの検索、作成、更新

#### APIトークンの取得
1. [Atlassian API tokens](https://id.atlassian.com/manage-profile/security/api-tokens) にアクセス
2. "Create API token"をクリック
3. ラベルを入力（例: "Claude MCP"）
4. 生成されたトークンをコピー

#### 使用可能な操作
- チケット検索
- チケット詳細の取得
- コメント追加
- ステータス更新

### Kibela MCP
**用途**: Kibelaの記事検索、作成、更新

#### アクセストークンの取得
1. Kibelaにログイン
2. 設定 → 個人アクセストークン
3. 新規トークン作成
4. 必要な権限を選択
5. トークンをコピー

#### 使用可能な操作
- 記事検索
- 記事の読み取り
- 記事の作成・更新
- フォルダ操作

### Figma MCP
**用途**: Figmaファイルへのアクセス、デザイン情報の取得

#### セットアップ
```bash
# HTTPトランスポートで自動設定
claude mcp add figma \
  --scope user \
  --transport http \
  https://mcp.figma.com/mcp
```

#### 使用可能な操作
- ファイル一覧取得
- コンポーネント情報取得
- スタイル情報取得

## MCPサーバー管理

### 登録済みサーバーの確認
```bash
# 一覧表示
claude mcp list

# 詳細表示
claude mcp info <server-name>
```

### サーバーの更新
```bash
# 既存のサーバーを削除
claude mcp remove <server-name>

# 再度追加
source ~/dotfiles/zsh/mcp.zsh
```

### サーバーの削除
```bash
claude mcp remove mcp-atlassian
claude mcp remove kibela
claude mcp remove figma
```

## トラブルシューティング

### 環境変数が見つからない
```bash
# 環境変数の確認
echo $JIRA_URL
echo $KIBELA_ORIGIN

# 設定ファイルの確認
cat ~/.secrets/claude-mcp.env

# 再読み込み
source ~/.secrets/claude-mcp.env
```

### MCPサーバーが動作しない
```bash
# Claude Codeを再起動
# プロセスを確認
ps aux | grep claude

# ログ確認（利用可能な場合）
tail -f ~/Library/Logs/claude/mcp.log
```

### 権限エラー
```bash
# Docker権限（Kibela MCPの場合）
# Dockerが起動していることを確認
docker ps

# Dockerグループに追加（Linux）
sudo usermod -aG docker $USER

# macOSの場合はDocker Desktopが起動していることを確認
```

### APIトークンが無効
1. 各サービスでトークンの有効性を確認
2. 必要に応じて新規トークンを生成
3. ~/.secrets/claude-mcp.envを更新
4. 環境変数を再読み込み
5. MCPサーバーを再登録

## セキュリティベストプラクティス

### 環境変数ファイルの保護
```bash
# 権限を制限
chmod 600 ~/.secrets/claude-mcp.env

# .gitignoreに追加
echo "~/.secrets/" >> ~/.gitignore
echo ".env" >> ~/.gitignore
```

### トークンのローテーション
- 定期的にAPIトークンを更新（3-6ヶ月ごと）
- 不要になったトークンは即座に無効化
- トークンは絶対にコミットしない

### アクセス権限の最小化
- 必要最小限の権限のみ付与
- 読み取り専用で十分な場合は書き込み権限を付与しない
- 定期的に権限設定を見直す

## カスタムMCPサーバーの追加

### 基本的な追加方法
```bash
# Node.jsベースのMCPサーバー
claude mcp add <server-name> \
  --scope user \
  -e ENV_VAR="value" \
  -- npx <package-name>

# Pythonベースのサーバー
claude mcp add <server-name> \
  --scope user \
  -e ENV_VAR="value" \
  -- uvx --python 3.13 <package-name>

# Dockerベースのサーバー
claude mcp add <server-name> \
  --scope user \
  -e ENV_VAR="value" \
  -- docker run -i <image-name>
```

### スコープオプション
- `--scope user`: 現在のユーザーのみ
- `--scope project`: プロジェクト固有（.claude/ディレクトリ内）

## 参考リンク
- [MCP公式ドキュメント](https://modelcontextprotocol.io/)
- [Atlassian API](https://developer.atlassian.com/cloud/jira/platform/)
- [Kibela API](https://support.kibe.la/hc/ja/articles/360035086952)