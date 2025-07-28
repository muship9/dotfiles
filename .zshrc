# ================================================================
# Zsh Configuration
# ================================================================

# ----------------------------------------------------------------
# System Paths
# ----------------------------------------------------------------
# Homebrew paths
export PATH="/usr/local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# Python user bin (for neovim-remote)
export PATH="$HOME/Library/Python/3.9/bin:$PATH"

# MySQL client
export PATH="/opt/homebrew/opt/mysql-client@8.0/bin:$PATH"

# ----------------------------------------------------------------
# Programming Language Managers
# ----------------------------------------------------------------
# Volta (Node.js version manager)
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# rbenv (Ruby version manager)
if command -v rbenv &> /dev/null; then
  export PATH="~/.rbenv/shims:/usr/local/bin:$PATH"
  eval "$(rbenv init -)"
fi

# nodenv (Node.js version manager - alternative to Volta)
if command -v nodenv &> /dev/null; then
  export PATH="$HOME/.nodenv/bin:$PATH"
  eval "$(nodenv init -)"
fi

# Go
if command -v go &> /dev/null; then
  export PATH="$PATH:$(go env GOPATH)/bin"
fi

# GVM (Go Version Manager)
if [[ -s "$HOME/.gvm/scripts/gvm" ]] && [[ -z "$GVM_INIT" ]]; then
  export GVM_INIT=1
  source "$HOME/.gvm/scripts/gvm"
fi

# Bun (JavaScript runtime and package manager)
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# ----------------------------------------------------------------
# Editor Configuration
# ----------------------------------------------------------------
# Default editor setup with neovim-remote support
if [[ -n "$NVIM" ]]; then
    # Inside Neovim terminal - use neovim-remote
    alias nvim="nvr -cc split --remote-wait +'set bufhidden=wipe'"
    alias vim="nvr -cc split --remote-wait +'set bufhidden=wipe'"
    export VISUAL="nvr -cc split --remote-wait +'set bufhidden=wipe'"
    export EDITOR="nvr -cc split --remote-wait +'set bufhidden=wipe'"
    export GIT_EDITOR="nvr -cc split --remote-wait +'set bufhidden=wipe'"
else
    # Normal shell - use neovim directly
    export VISUAL="nvim"
    export EDITOR="nvim"
    export GIT_EDITOR="nvim"
fi

# ----------------------------------------------------------------
# Shell Enhancements
# ----------------------------------------------------------------
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

# ----------------------------------------------------------------
# Custom Functions
# ----------------------------------------------------------------
# Enhanced history search with fzf
function select-history() {
  BUFFER=$(history -n -r 1 | fzf --no-sort +m --query "$LBUFFER" --prompt="History > ")
  CURSOR=$#BUFFER
  zle reset-prompt
}
zle -N select-history
bindkey '^r' select-history

# ----------------------------------------------------------------
# Aliases
# ----------------------------------------------------------------
alias nv='nvim .'
alias idea="open -na 'IntelliJ IDEA' --args"

# ----------------------------------------------------------------
# External Tools
# ----------------------------------------------------------------
# Windsurf (Codeium)
export PATH="/Users/mukaiyamashinpei/.codeium/windsurf/bin:$PATH"

# ----------------------------------------------------------------
# Environment Files
# ----------------------------------------------------------------
# Load dotfiles environment variables
if [[ -f "$HOME/dotfiles/.env" ]]; then
  set -a
  source "$HOME/dotfiles/.env"
  set +a
fi

# Load work-specific configuration
[[ -s "/Users/mukaiyamashinpei/dotfiles/work.zsh" ]] && source "/Users/mukaiyamashinpei/dotfiles/work.zsh"
