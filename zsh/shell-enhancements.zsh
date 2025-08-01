# ================================================================
# Shell Enhancements Configuration
# ================================================================

# Zsh plugins (installed via Homebrew)
if [[ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if [[ -f "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Starship prompt
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

# fzf key bindings and completion
if command -v fzf &> /dev/null; then
  source <(fzf --zsh)
fi

# direnv for directory-specific environment variables
if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi