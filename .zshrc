# HomeBrew
export PATH="/usr/local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# Zsh Plugin
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# starship
eval "$(starship init zsh)"

# Volta
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# rbenv
export PATH="~/.rbenv/shims:/usr/local/bin:$PATH"
eval "$(rbenv init -)"

# nodenv
export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"

# VIM
export EDITOR=nvim
eval "$(direnv hook zsh)"

# Python user bin (for nvr)
export PATH="$HOME/Library/Python/3.9/bin:$PATH"

# Neovim Remote (nvr) configuration
# Use nvr when inside neovim terminal
if [ -n "$NVIM" ]; then
    alias nvim="nvr -cc split --remote-wait +'set bufhidden=wipe'"
    alias vim="nvr -cc split --remote-wait +'set bufhidden=wipe'"
    export VISUAL="nvr -cc split --remote-wait +'set bufhidden=wipe'"
    export EDITOR="nvr -cc split --remote-wait +'set bufhidden=wipe'"
    export GIT_EDITOR="nvr -cc split --remote-wait +'set bufhidden=wipe'"
else
    export VISUAL="nvim"
    export EDITOR="nvim"
    export GIT_EDITOR="nvim"
fi

# go
if command -v go &> /dev/null; then
  export PATH=$PATH:$(go env GOPATH)/bin
fi

# Load .env file if it exists
if [ -f "$HOME/dotfiles/.env" ]; then
  set -a
  source "$HOME/dotfiles/.env"
  set +a
fi

# alias
alias nv='nvim .'
alias idea="open -na 'IntelliJ IDEA' --args"

# GVM - Go Version Manager
if [[ -s "/Users/SHINP09/.gvm/scripts/gvm" ]] && [[ -z "$GVM_INIT" ]]; then
  export GVM_INIT=1
  source "/Users/SHINP09/.gvm/scripts/gvm"
fi
export PATH="/opt/homebrew/opt/mysql-client@8.0/bin:$PATH"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# bun completions
[ -s "/Users/mukaiyamashinpei/.bun/_bun" ] && source "/Users/mukaiyamashinpei/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Added by Windsurf
export PATH="/Users/mukaiyamashinpei/.codeium/windsurf/bin:$PATH"

function select-history() {
  BUFFER=$(history -n -r 1 | fzf --no-sort +m --query "$LBUFFER" --prompt="History > ")
  CURSOR=$#BUFFER
  zle reset-prompt
}
zle -N select-history
bindkey '^r' select-history

[[ -s "/Users/mukaiyamashinpei/dotfiles/work.zsh" ]] && source "/Users/mukaiyamashinpei/dotfiles/work.zsh"
