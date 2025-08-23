# ================================================================
# Aliases Configuration
# ================================================================

# Editor aliases
alias nv='nvim .'
alias idea="open -na 'IntelliJ IDEA' --args"

# Git aliases
alias gst='git status'
alias gb='git branch'
alias ga='git add'
alias gc='git commit -m'
alias gp='git pull origin $(git branch --show-current)'
alias gpu='git push origin $(git branch --show-current)'
alias gf='git fetch'
alias gs='git switch'
# 新規ブランチを作成して切り替え
alias gsc='git switch -c'
alias gch='git checkout'

# Directory navigation aliases
alias .='cd ./'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias cdot='cd ~/dotfiles'
alias cdw='cd ~/workspace'
alias cdesk='cd ~/Desktop'
alias cdoc='cd ~/Documents'
alias cdl='cd ~/Downloads'
