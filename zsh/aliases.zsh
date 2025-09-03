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
alias gd='git diff'

# Directory navigation aliases
# Note: . is reserved for source command, using cd. instead
# Directory navigation helpers (avoid overriding POSIX '.')
c.() {
    if [ $# -eq 0 ]; then
        cd ./
    else
        cd "$1"
    fi
}

c..() {
    if [ $# -eq 0 ]; then
        cd ..
    else
        cd "../$1"
    fi
}

c...() {
    if [ $# -eq 0 ]; then
        cd ../..
    else
        cd "../../$1"
    fi
}

c....() {
    if [ $# -eq 0 ]; then
        cd ../../..
    else
        cd "../../../$1"
    fi
}

alias ~='cd ~'
alias cdot='cd ~/dotfiles'
alias cdw='cd ~/workspace'
alias cdesk='cd ~/Desktop'
alias cdoc='cd ~/Documents'
alias cdl='cd ~/Downloads'

# Git root directory navigation
alias root='cd $(git rev-parse --show-toplevel 2>/dev/null || pwd)'

# Obsidian aliases
alias obs='cd ~/Documents/Obsidian\ Vault && nvim'
alias obd='cd ~/Documents/Obsidian\ Vault && nvim daily/$(date +%Y-%m-%d).md'
alias oby='echo -e "\n---\n$(date +"%H:%M")\n" >> ~/Documents/Obsidian\ Vault/daily/$(date +%Y-%m-%d).md && pbpaste >> ~/Documents/Obsidian\ Vault/daily/$(date +%Y-%m-%d).md && echo "✅ クリップボードの内容をデイリーノートに追加しました"'
