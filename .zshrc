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

# ----- git -------
alias gco='git checkout'
alias gnb="git checkout -b"
alias gp="git pull"
alias ga="git add"
alias gcm="git commit"
alias gpsh="git push origin HEAD"

[[ -s "/Users/SHINP09/.gvm/scripts/gvm" ]] && source "/Users/SHINP09/.gvm/scripts/gvm"
export PATH="/opt/homebrew/opt/mysql-client@8.0/bin:$PATH"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

gate() {
  local instance
  instance="$(aws-gate list | cut -f 1,2 -d ' ' | fzf --reverse --ansi | cut -f 1 -d ' ')"
  if [ "${instance}" = "" ]; then
    return 1
  fi
  aws-gate session ${instance}
}
gate-dev() {
  instance=$(aws-gate list --profile dev | cut -f 1,2 -d ' ' | fzf --reverse --ansi | cut -f 1 -d ' ')
  if [[ -z "$instance" ]]; then
    return 1
  fi
  aws-gate session $instance --profile dev
}
