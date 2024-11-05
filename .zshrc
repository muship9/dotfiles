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

# vim
export EDITOR=vim
eval "$(direnv hook zsh)"

# Go
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
