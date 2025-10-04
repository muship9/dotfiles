# ================================================================
# Zsh Configuration
# ================================================================

# Detect dotfiles directory robustly
if [[ -z "${DOTFILES_DIR:-}" ]]; then
  # Try typical locations
  if [[ -d "$HOME/dotfiles" ]]; then
    DOTFILES_DIR="$HOME/dotfiles"
  elif [[ -d "$HOME/.dotfiles" ]]; then
    DOTFILES_DIR="$HOME/.dotfiles"
  else
    # Fallback: resolve from this file location if symlinked
    # In zsh, ${(%):-%N} is current script path when sourced
    __zshrc_path="${(%):-%N}"
    if [[ -n "$__zshrc_path" && -e "$__zshrc_path" ]]; then
      DOTFILES_DIR="$(cd "$(dirname "$__zshrc_path")" && pwd)"
    else
      DOTFILES_DIR="$HOME/dotfiles"
    fi
    unset __zshrc_path
  fi
fi

# Load modular zsh configurations (only if files exist)
for f in \
  "$DOTFILES_DIR/zsh/paths.zsh" \
  "$DOTFILES_DIR/zsh/language-managers.zsh" \
  "$DOTFILES_DIR/zsh/editor.zsh" \
  "$DOTFILES_DIR/zsh/shell-enhancements.zsh" \
  "$DOTFILES_DIR/zsh/functions.zsh" \
  "$DOTFILES_DIR/zsh/aliases.zsh" \
  "$DOTFILES_DIR/zsh/environment.zsh"; do
  [[ -s "$f" ]] && source "$f"
done

# Load work-specific configuration
[[ -s "$DOTFILES_DIR/zsh/work.zsh" ]] && source "$DOTFILES_DIR/zsh/work.zsh"

# Created by `pipx` on 2025-10-01 08:22:47
export PATH="$PATH:/Users/shinpeimukaiyama/.local/bin"
