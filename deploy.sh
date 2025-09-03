#!/usr/bin/env bash
set -euo pipefail

# 適用元ディレクトリ（このスクリプトが置かれているリポジトリルート）
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Dotfiles: $DOTFILES_DIR からリンクを作成します"

mkdir -p "$HOME/.config"
mkdir -p "$HOME/.config/git"

link() {
  local src="$1"
  local dest="$2"
  mkdir -p "$(dirname "$dest")"
  ln -snfv "$src" "$dest"
}

# zsh
link "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

# starship
link "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

# wezterm
link "$DOTFILES_DIR/wezterm" "$HOME/.config/wezterm"

# neovim
link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

# git global ignore
link "$DOTFILES_DIR/git/ignore" "$HOME/.config/git/ignore"

echo "Gitのグローバルignoreを設定するには、次を実行してください:"
echo "  git config --global core.excludesFile \"$HOME/.config/git/ignore\""

# .codex ディレクトリが存在しない場合は作成
if [ ! -d ~/.codex ]; then
  mkdir -p ~/.codex
fi

# ai/codex.md を ~/.codex/AGENTS.md としてシンボリックリンクを作成
ln -svf ~/dotfiles/ai/codex.md ~/.codex/AGENTS.md
