# ================================================================
# Aliases Configuration
# ================================================================

# Editor aliases
alias nv='nvim'
alias idea="open -na 'IntelliJ IDEA' --args"

# Git aliases
alias gst='git status'
alias gb='git branch'
alias ga='git add'
alias gcm='git commit -m'
alias gp='git pull origin $(git branch --show-current)'
alias gpu='git push origin $(git branch --show-current)'
alias gf='git fetch'
alias gsw='git switch'
alias gswc='git switch -c'
alias gch='git checkout .'
alias gd='git diff'
alias gm='git merge'

alias ~='cd ~'
alias cdot='cd ~/dotfiles'
alias cw='cd ~/workspace'
alias cdesc='cd ~/Desktop'
alias cdoc='cd ~/Documents'
alias cdl='cd ~/Downloads'

# Git root directory navigation
alias root='cd $(git rev-parse --show-toplevel 2>/dev/null || pwd)'

# Obsidian aliases
alias obs='cd ~/Documents/Obsidian\ Vault && nvim'
alias obd='cd ~/Documents/Obsidian\ Vault && nvim daily/$(date +%Y-%m-%d).md'
alias oby='echo -e "\n---\n$(date +"%H:%M")\n" >> ~/Documents/Obsidian\ Vault/daily/$(date +%Y-%m-%d).md && pbpaste >> ~/Documents/Obsidian\ Vault/daily/$(date +%Y-%m-%d).md && echo "✅ クリップボードの内容をデイリーノートに追加しました"'
