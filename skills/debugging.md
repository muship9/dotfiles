# Debugging & Troubleshooting

## 概要
各種エラーや問題が発生した際のトラブルシューティング手順。
Neovim、Zsh、シンボリックリンク、Git関連の問題解決方法。

## Neovim関連

### 起動しない・エラーが出る
```bash
# 1. ヘルスチェック
nvim --headless "+checkhealth" +qa

# 2. 最小構成で起動
nvim --clean  # プラグインなしで起動

# 3. デバッグモード
nvim -V  # 詳細ログ表示
nvim -V20/tmp/nvim.log  # ログをファイルに保存

# 4. エラーメッセージ確認
nvim +"messages" +qa
```

### プラグインが動作しない
```vim
" Neovim内で実行
:Lazy  " プラグインマネージャUI
:Lazy log  " 更新ログ確認
:Lazy profile  " パフォーマンス分析
:Lazy debug  " デバッグ情報

" 特定プラグインのリロード
:Lazy reload plugin-name
```

### LSPが動作しない
```vim
" LSP状態確認
:LspInfo
:LspLog  " ログ確認

" Masonで再インストール
:Mason
:MasonInstall lua-language-server

" 手動で再起動
:LspRestart
```

### キャッシュクリア（完全リセット）
```bash
# Neovimのデータを全削除（注意：設定以外も削除される）
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim

# プラグイン再インストール
nvim --headless "+Lazy sync" +qa
```

## Zsh関連

### 起動が遅い
```bash
# プロファイリング
time zsh -i -c exit  # 起動時間測定

# 詳細なプロファイリング
zsh -xv  # 実行される全コマンドを表示

# zprof を使用（.zshrcの最初と最後に追加）
# 最初: zmodload zsh/zprof
# 最後: zprof
```

### エイリアスが効かない
```bash
# エイリアス確認
alias | grep <alias-name>

# ファイルの読み込み確認
echo $DOTFILES_DIR  # 正しいパスか確認
ls -la ~/dotfiles/zsh/aliases.zsh

# 手動で読み込み
source ~/dotfiles/zsh/aliases.zsh
```

### 環境変数の問題
```bash
# 環境変数の確認
env | grep <variable-name>
echo $PATH | tr ':' '\n'  # PATH を見やすく表示

# PATHの重複削除
typeset -U PATH  # zshでPATHの重複を削除
```

## シンボリックリンク関連

### リンクが壊れている
```bash
# リンク状態確認
ls -la ~/.config/nvim
ls -la ~/.zshrc

# リンク先の確認
readlink ~/.config/nvim

# 再作成
rm ~/.config/nvim
ln -s ~/dotfiles/nvim ~/.config/nvim
```

### deploy.shが失敗する
```bash
# デバッグモードで実行
bash -x deploy.sh

# 手動でリンク作成
ln -snfv ~/dotfiles/nvim ~/.config/nvim
```

## Git関連

### global ignoreが効かない
```bash
# 設定確認
git config --global core.excludesFile

# 再設定
git config --global core.excludesFile "$HOME/.config/git/ignore"

# ファイル確認
cat ~/.config/git/ignore
```

## 一般的なデバッグテクニック

### ログの確認
```bash
# システムログ（macOS）
log show --predicate 'process == "nvim"' --last 1h

# エラーのみ表示
log show --predicate 'process == "nvim" && messageType == error' --last 1h
```

### プロセスの確認
```bash
# 実行中のプロセス
ps aux | grep nvim
pgrep -l nvim

# プロセスの強制終了
pkill nvim
killall nvim
```

### ファイル/ディレクトリの権限
```bash
# 権限確認
ls -la ~/.config/
stat ~/.config/nvim

# 権限修正
chmod -R 755 ~/.config/nvim
```

## よくある問題と解決策

### "command not found"
```bash
# PATHを確認
echo $PATH
which <command-name>

# Homebrewのパスを追加
export PATH="/opt/homebrew/bin:$PATH"  # M1 Mac
export PATH="/usr/local/bin:$PATH"     # Intel Mac
```

### "permission denied"
```bash
# 実行権限を付与
chmod +x <file>

# 所有者を変更
chown -R $(whoami) ~/.config/nvim
```

### メモリ不足
```bash
# Neovimのメモリ使用量確認
top -o mem | grep nvim

# スワップファイルのクリア
rm ~/.local/state/nvim/swap/*
```

## 緊急時のリカバリ

### 設定のバックアップと復元
```bash
# バックアップ
cp -r ~/.config/nvim ~/.config/nvim.bak
cp ~/.zshrc ~/.zshrc.bak

# 復元
mv ~/.config/nvim.bak ~/.config/nvim
mv ~/.zshrc.bak ~/.zshrc
```

### 工場出荷状態に戻す
```bash
# 全設定を削除（注意！）
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
rm ~/.zshrc

# dotfilesから再セットアップ
cd ~/dotfiles
./deploy.sh
```