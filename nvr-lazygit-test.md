# LazyGit + nvr (neovim-remote) 動作確認手順

## 設定完了内容

以下の設定を完了しました：

1. **Neovimのサーバー設定** (`nvim/lua/config/options.lua`)
   - `v:servername`を自動設定
   - `NVIM`環境変数を自動エクスポート

2. **シェル設定** (`.zshrc`)
   - Neovim内で`nvr`を使用するための環境変数設定
   - `EDITOR`, `VISUAL`, `GIT_EDITOR`の自動切り替え

3. **LazyGit設定** (`~/.config/lazygit/config.yml`)
   - `editCommand`をnvrのフルパスに設定
   - `editCommandTemplate`を適切な形式に設定

4. **lazygit.nvimプラグイン設定** (`nvim/lua/plugins/editor.lua`)
   - nvrバイナリのフルパス指定
   - TermOpen時の環境変数設定

## 動作確認手順

### 1. 設定の反映

```bash
# 新しいターミナルセッションを開くか、以下を実行
source ~/.zshrc

# Neovimを再起動
```

### 2. Neovimサーバーの確認

Neovim内で以下を実行：

```vim
:echo v:servername
" 例: /tmp/nvim-12345.sock のような値が表示されるはず

:echo $NVIM
" 上記と同じ値が表示されるはず
```

### 3. LazyGit内でのファイル編集テスト

1. Neovimを起動
2. `<leader>gg`でLazyGitを開く
3. 任意のファイルで`e`キーを押してファイルを編集
4. ファイルが現在のNeovimインスタンス内の新しいタブで開かれることを確認

### 4. コミットメッセージ編集テスト

1. LazyGit内で変更をステージング
2. `c`キーを押してコミット
3. コミットメッセージエディタが現在のNeovimインスタンス内で開かれることを確認
4. メッセージを書いて保存(`:wq`)
5. LazyGitに戻ることを確認

### 5. トラブルシューティング

問題が発生した場合：

```bash
# nvr が正しくインストールされているか確認
which nvr
nvr --version

# Neovim内で環境変数を確認
:echo $NVIM
:echo $EDITOR
:echo $GIT_EDITOR

# LazyGit内で環境変数を確認（LazyGitを開いてから）
# ターミナルモードで :!echo $NVIM
```

### 6. 代替設定

もし上記の設定で動作しない場合、以下の代替設定を試してください：

**LazyGit設定の代替案** (`~/.config/lazygit/config.yml`):

```yaml
os:
  editCommand: '{{.Env.EDITOR}}'
  editCommandTemplate: '{{editor}} +{{line}} {{filename}}'
```

これにより、環境変数`EDITOR`の値が使用されます。