# Neovim Plugin Management

## 概要
Neovimプラグインの追加・更新・削除手順。
lazy.nvimとMason.nvimを使用したプラグイン/LSPサーバー管理方法。

## プラグインの追加

### 1. 新規プラグインファイル作成
```bash
# 機能に応じたファイルに追加、または新規作成
nvim nvim/lua/plugins/new-feature.lua
```

### 2. プラグイン定義の書き方
```lua
-- nvim/lua/plugins/new-feature.lua
return {
  {
    "author/plugin-name",
    -- 遅延読み込み設定
    event = "VeryLazy",  -- または "BufRead", "BufNewFile" など
    -- または
    cmd = "CommandName",  -- コマンド実行時に読み込み
    -- または
    keys = {  -- キーマップ実行時に読み込み
      { "<leader>xx", "<cmd>CommandName<cr>", desc = "Description" },
    },
    
    -- 依存関係
    dependencies = {
      "dependency/plugin",
    },
    
    -- 設定
    config = function()
      require("plugin-name").setup({
        -- オプション
      })
    end,
  },
}
```

### 3. プラグインのインストール
```bash
# Neovim内で
:Lazy sync

# またはコマンドラインから
nvim --headless "+Lazy sync" +qa
```

## プラグインの更新

### 全プラグイン更新
```vim
:Lazy update
```

### 特定プラグインのみ更新
```vim
:Lazy update plugin-name
```

### 更新後のクリーンアップ
```vim
:Lazy clean  " 未使用プラグインを削除
```

## LSPサーバー管理（Mason）

### LSPサーバーのインストール
```vim
:Mason
" UIから選択してインストール

" または直接
:MasonInstall lua-language-server
:MasonInstall stylua
:MasonInstall typescript-language-server
```

### インストール済み確認
```vim
:MasonList
```

### 自動インストール設定
```lua
-- nvim/lua/plugins/lsp.lua 内で設定
ensure_installed = {
  "lua_ls",
  "tsserver",
  "rust_analyzer",
  -- 他のサーバー
}
```

## プラグインの削除

### 1. 設定ファイルから削除
```bash
# 該当プラグインの設定を削除またはコメントアウト
nvim nvim/lua/plugins/target.lua
```

### 2. クリーンアップ
```vim
:Lazy clean
```

## プラグインのトラブルシューティング

### プラグインの状態確認
```vim
:Lazy
" UIで各プラグインの状態を確認
```

### プラグインのプロファイリング
```vim
:Lazy profile
" 起動時間の分析
```

### キャッシュクリア
```bash
# lazy.nvimのキャッシュをクリア
rm -rf ~/.local/share/nvim/lazy
rm -rf ~/.local/state/nvim/lazy

# 再インストール
nvim --headless "+Lazy sync" +qa
```

### ログ確認
```vim
:Lazy log
" プラグインの更新ログ確認
```

## よく使うプラグイン操作

### 検索
```vim
:Telescope lazy  " インストール済みプラグイン検索
```

### ヘルプ
```vim
:help lazy.nvim
:help mason.nvim
```

### 設定の再読み込み
```vim
:source %  " 現在のファイルを再読み込み
:Lazy reload plugin-name  " 特定プラグインをリロード
```

## プラグイン追加のベストプラクティス

1. **最小限の設定から始める**
   - 基本的な設定のみで動作確認
   - 必要に応じて設定を追加

2. **遅延読み込みを活用**
   - `event`, `cmd`, `keys` で必要時のみ読み込み
   - 起動速度の改善

3. **既存プラグインとの競合確認**
   - 類似機能のプラグインがないか確認
   - キーマップの重複をチェック

4. **定期的なメンテナンス**
   - 週1回程度 `:Lazy update` を実行
   - 不要なプラグインは削除