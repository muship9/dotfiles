#!/bin/bash
# Claude Code MCP サーバーのセットアップスクリプト
# 新しいマシンでのセットアップ時や、MCP を再設定する際に実行する

set -e

required_vars=(JIRA_URL JIRA_USERNAME JIRA_API_TOKEN KIBELA_ORIGIN KIBELA_ACCESS_TOKEN)
missing=()

for var in "${required_vars[@]}"; do
  if [ -z "${(P)var}" ]; then
    missing+=("$var")
  fi
done

if [ ${#missing[@]} -ne 0 ]; then
  echo "Error: 以下の環境変数が設定されていません:"
  for var in "${missing[@]}"; do
    echo "  - $var"
  done
  echo ""
  echo "~/.secrets/claude-mcp.env を作成して source してください"
  echo "  cp ~/dotfiles/templates/claude-mcp.env.example ~/.secrets/claude-mcp.env"
  exit 1
fi

echo "==> Atlassian MCP を登録..."
claude mcp add mcp-atlassian \
  --scope user \
  -e JIRA_URL="$JIRA_URL" \
  -e JIRA_USERNAME="$JIRA_USERNAME" \
  -e JIRA_API_TOKEN="$JIRA_API_TOKEN" \
  -- uvx --python 3.13 mcp-atlassian \
  || echo "  (スキップ: 既に登録済み)"

echo "==> Kibela MCP を登録..."
claude mcp add kibela \
  --scope user \
  -e KIBELA_ORIGIN="$KIBELA_ORIGIN" \
  -e KIBELA_ACCESS_TOKEN="$KIBELA_ACCESS_TOKEN" \
  -- docker run -i \
    -e KIBELA_ORIGIN \
    -e KIBELA_ACCESS_TOKEN \
    ghcr.io/kibela/kibela-mcp-server \
  || echo "  (スキップ: 既に登録済み)"

echo "==> Figma MCP を登録..."
claude mcp add figma \
  --scope user \
  --transport http \
  https://mcp.figma.com/mcp \
  || echo "  (スキップ: 既に登録済み)"

echo ""
echo "==> 登録済み MCP サーバー:"
claude mcp list

echo ""
echo "完了! Claude Code を再起動してください。"
