# Deployment & Setup

## 概要
dotfilesの初回セットアップ、更新、新マシンへの移行手順。
deploy.shスクリプトの動作内容とカスタマイズ方法。

## 初回セットアップ

### 1. 必要なツールのインストール
```bash
# Homebrew (macOS)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 基本ツール
brew install neovim git node ripgrep fd starship wezterm direnv
```

### 2. dotfilesのクローン
```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
```

### 3. デプロイスクリプト実行
```bash
chmod +x deploy.sh
./deploy.sh
```

### 4. シェル設定の反映
```bash
source ~/.zshrc
```

## deploy.shの動作内容

### 自動実行される処理
1. Homebrew パッケージのインストール
   - zsh-autosuggestions
   - zsh-syntax-highlighting

2. シンボリックリンクの作成
   - `~/.zshrc` → `~/dotfiles/.zshrc`
   - `~/.config/starship.toml` → `~/dotfiles/starship/starship.toml`
   - `~/.config/wezterm` → `~/dotfiles/wezterm`
   - `~/.config/nvim` → `~/dotfiles/nvim`
   - `~/.config/git/ignore` → `~/dotfiles/git/ignore`
   - `~/.codex/AGENTS.md` → `~/dotfiles/ai/codex.md`

## 設定更新時の手順

### 軽微な変更（エイリアス追加など）
```bash
cd ~/dotfiles
git pull
source ~/.zshrc  # zsh設定の場合のみ
```

### 構造的な変更（新規ファイル追加など）
```bash
cd ~/dotfiles
git pull
./deploy.sh  # リンクの再作成
source ~/.zshrc
```

### Neovimプラグイン更新後
```bash
# プラグインの同期
nvim --headless "+Lazy sync" +qa

# ヘルスチェック
nvim --headless "+checkhealth" +qa
```

## 新しいマシンへの移行

### 完全セットアップ手順
```bash
# 1. Homebrewインストール
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. 基本ツールインストール
brew install neovim git node ripgrep fd starship wezterm direnv
brew install zsh-autosuggestions zsh-syntax-highlighting

# 3. dotfilesクローン & セットアップ
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
chmod +x deploy.sh
./deploy.sh

# 4. Neovimプラグインインストール
nvim --headless "+Lazy sync" +qa

# 5. Git設定
git config --global core.excludesFile "$HOME/.config/git/ignore"

# 6. シェル再起動
exec $SHELL
```

## カスタマイズ

### deploy.shに新しいリンクを追加
```bash
# deploy.sh 内に追加
link "$DOTFILES_DIR/new-config" "$HOME/.config/new-config"
```

### 環境固有の設定
```bash
# work.zsh を作成（gitignoreに追加済み）
echo 'export WORK_SPECIFIC_VAR="value"' > ~/dotfiles/zsh/work.zsh
```

## セットアップの検証

### リンクの確認
```bash
# シンボリックリンクが正しいか確認
ls -la ~/.zshrc
ls -la ~/.config/nvim
ls -la ~/.config/starship.toml
```

### Neovimの動作確認
```bash
# ヘルスチェック
nvim --headless "+checkhealth" +qa

# プラグインの状態
nvim +"Lazy" +qa
```

### Zsh設定の検証
```bash
# 文法チェック
zsh -n ~/.zshrc
for f in ~/dotfiles/zsh/*.zsh; do zsh -n "$f"; done
```

## トラブルシューティング

### リンクが作成されない
```bash
# 既存ファイルを確認
ls -la ~/.config/

# 手動でバックアップ後、再実行
mv ~/.config/nvim ~/.config/nvim.bak
./deploy.sh
```

### Neovimが起動しない
```bash
# キャッシュクリア
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim

# 再インストール
nvim --headless "+Lazy sync" +qa
```

### Zshが遅い
```bash
# プロファイリング
zsh -xvs

# 不要なプラグインを無効化
# ~/.zshrc 内で該当行をコメントアウト
```