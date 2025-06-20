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
export EDITOR=vim
eval "$(direnv hook zsh)"

# go
export PATH=$PATH:$(go env GOPATH)/bin

# alias
alias nv='nvim .'
alias idea="open -na 'IntelliJ IDEA' --args"

[[ -s "/Users/SHINP09/.gvm/scripts/gvm" ]] && source "/Users/SHINP09/.gvm/scripts/gvm"
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

[[ -s "./work.zsh" ]] && source "./work.zsh"
