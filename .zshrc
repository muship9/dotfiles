# ================================================================
# Zsh Configuration
# ================================================================

# Get dotfiles directory (assuming .zshrc is in dotfiles)
DOTFILES_DIR="$HOME/dotfiles"

# Load modular zsh configurations
source "$DOTFILES_DIR/zsh/paths.zsh"
source "$DOTFILES_DIR/zsh/language-managers.zsh"
source "$DOTFILES_DIR/zsh/editor.zsh"
source "$DOTFILES_DIR/zsh/shell-enhancements.zsh"
source "$DOTFILES_DIR/zsh/functions.zsh"
source "$DOTFILES_DIR/zsh/aliases.zsh"
source "$DOTFILES_DIR/zsh/environment.zsh"

# Load work-specific configuration
[[ -s "$DOTFILES_DIR/zsh/work.zsh" ]] && source "$DOTFILES_DIR/zsh/work.zsh"
