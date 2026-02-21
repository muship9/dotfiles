# Lint & Format Commands

## 概要
コード品質を保つためのlint/format/typecheckコマンド集。
Neovim(Lua)、Shell Scripts(Bash/Zsh)の検証とフォーマット手順を提供。

## Neovim (Lua)

### フォーマット
```bash
# Neovim内でフォーマット
nvim +"ConformFormat" +qa

# styluaで直接フォーマット
stylua nvim/

# 特定ファイルのみ
stylua nvim/lua/config/keymaps.lua
```

### 文法チェック
```bash
# Neovimヘルスチェック
nvim --headless "+checkhealth" +qa

# luacheckを使う場合（要インストール）
luacheck nvim/lua/
```

## Shell Scripts

### Bash
```bash
# 文法チェック
bash -n deploy.sh

# shellcheckによる詳細チェック
shellcheck deploy.sh

# 複数ファイルを一括チェック
shellcheck deploy.sh zsh/*.zsh
```

### Zsh
```bash
# 文法チェック
zsh -n zsh/aliases.zsh

# 全てのzshファイルをチェック
for f in zsh/*.zsh; do
  echo "Checking $f..."
  zsh -n "$f"
done
```

## 自動フォーマット設定

### Neovim保存時の自動フォーマット
- `:w` で保存時に自動的にConformが実行される
- 無効化: `:ConformDisable`
- 有効化: `:ConformEnable`

### 手動フォーマット
```vim
" Neovim内で実行
:ConformFormat
:ConformInfo  " フォーマッター情報確認
```

## プロジェクト全体のチェック

### 実行前チェックリスト
```bash
# 1. Lua設定のフォーマット
stylua nvim/

# 2. Shellスクリプトのチェック
shellcheck deploy.sh zsh/*.zsh
bash -n deploy.sh

# 3. Zsh設定のチェック
for f in zsh/*.zsh; do zsh -n "$f"; done

# 4. Neovimプラグインの同期
nvim --headless "+Lazy sync" +qa

# 5. ヘルスチェック
nvim --headless "+checkhealth" +qa
```

## トラブルシューティング

### styluaがない場合
```bash
# Masonでインストール
nvim +"MasonInstall stylua" +qa

# または直接インストール
brew install stylua
```

### shellcheckがない場合
```bash
brew install shellcheck
```

### フォーマッターが動作しない
```vim
" Neovim内で確認
:ConformInfo
:Mason
```