# Coding Standards

## 概要
プロジェクト全体のコーディング規約と命名規則。
Lua、Shell Scripts、Zshそれぞれの記述ルールとベストプラクティス。

## Lua (Neovim設定)

### 基本ルール
- **インデント**: タブ (設定に従う)
- **命名規則**: snake_case
- **文字列**: ダブルクォート優先
- **テーブル**: 末尾カンマを付ける

### コード例
```lua
local config = {
  option_name = "value",
  nested_table = {
    key = "value",
  },  -- 末尾カンマ
}

local function my_function(param_name)
  -- 関数内容
end
```

### フォーマッター設定
- **ツール**: stylua
- **実行**: `:ConformFormat` または保存時自動
- **設定ファイル**: `.stylua.toml` (プロジェクトルート)

## Shell Scripts (Bash)

### 基本ルール
- **シェバング**: `#!/usr/bin/env bash`
- **エラーハンドリング**: `set -euo pipefail`
- **命名規則**: ハイフン区切り (例: `deploy-script.sh`)
- **変数**: 大文字スネークケース `VARIABLE_NAME`
- **関数**: 小文字スネークケース `function_name()`

### テンプレート
```bash
#!/usr/bin/env bash
set -euo pipefail

# グローバル変数
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VARIABLE_NAME="value"

# 関数定義
function_name() {
  local local_var="$1"
  echo "Processing: $local_var"
}

# メイン処理
main() {
  function_name "$VARIABLE_NAME"
}

# スクリプトが直接実行された場合のみmainを実行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
```

### 検証
```bash
# 文法チェック
bash -n script.sh

# 詳細チェック
shellcheck script.sh
```

## Zsh設定

### エイリアス
- **命名パターン**: 短縮形を維持
- **グルーピング**: 機能別にファイル分割
- **例**:
  ```zsh
  # Git関連 (短縮形)
  alias gd='git diff'
  alias gst='git status'
  alias ga='git add'
  
  # ディレクトリ移動
  alias ..='cd ..'
  alias ...='cd ../..'
  ```

### 関数
```zsh
# 関数名は小文字、アンダースコア区切り
function my_custom_function() {
  local param="$1"
  echo "Executing: $param"
}

# または短縮形
my_func() {
  # 処理
}
```

### 環境変数
```zsh
# 大文字スネークケース
export MY_CUSTOM_PATH="$HOME/custom/path"
export EDITOR="nvim"

# PATH追加時は重複防止
typeset -U PATH
export PATH="$HOME/bin:$PATH"
```

## ファイル・ディレクトリ命名

### 一般ルール
- **ディレクトリ**: 小文字、ハイフン区切り
- **設定ファイル**: 小文字、ハイフン区切り
- **Luaファイル**: 小文字、アンダースコア区切り
- **Shellスクリプト**: 小文字、ハイフン区切り

### 例
```
dotfiles/
├── nvim/
│   └── lua/
│       ├── config/
│       │   └── keymaps.lua      # Luaファイル: アンダースコア
│       └── plugins/
│           └── lsp-config.lua    # ハイフンも可
├── zsh/
│   ├── aliases.zsh              # Zsh設定: 小文字
│   └── environment.zsh
├── scripts/
│   └── deploy-script.sh         # スクリプト: ハイフン区切り
└── docs/
    └── setup-guide.md            # ドキュメント: ハイフン区切り
```

## コメント規約

### Lua
```lua
-- 単一行コメント
-- 関数の説明は上部に記載

--[[
  複数行コメント
  詳細な説明が必要な場合
]]

-- TODO: 実装予定の機能
-- FIXME: 修正が必要な箇所
-- NOTE: 重要な注意事項
```

### Shell
```bash
# 単一行コメント
# 関数の説明は上部に記載

# TODO: 実装予定の機能
# FIXME: 修正が必要な箇所
# NOTE: 重要な注意事項

: <<'COMMENT'
複数行コメント
詳細な説明が必要な場合
COMMENT
```

## ベストプラクティス

### エラーハンドリング
- Bashスクリプトでは必ず `set -euo pipefail` を使用
- 重要な処理には適切なエラーメッセージを追加
- 終了コードを意識的に設定

### セキュリティ
- 環境変数やシークレットをハードコードしない
- `.gitignore` で機密ファイルを除外
- `shellcheck` で潜在的な問題を検出

### 保守性
- 関数は単一責任の原則に従う
- マジックナンバーは定数として定義
- 複雑なロジックには適切なコメントを追加

### パフォーマンス
- Neovimプラグインは遅延読み込みを活用
- 不要なグローバル変数は避ける
- シェルスクリプトでは外部コマンドの呼び出しを最小限に