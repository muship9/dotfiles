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
alias gswm='git switch main'
alias gch='git checkout .'
alias gd='git diff'
alias gm='git merge'

alias ~='cd ~'
alias cdot='cd ~/dotfiles'
alias cw='cd ~/workspace'
alias cdesc='cd ~/Desktop'
alias cdoc='cd ~/Documents'
alias cdl='cd ~/Downloads'
alias cm='cd ~/memo/'

# Git root directory navigation
alias root='cd $(git rev-parse --show-toplevel 2>/dev/null || pwd)'

# Obsidian aliases
alias obs='cd ~/Documents/Obsidian\ Vault && nvim'
alias obd='cd ~/Documents/Obsidian\ Vault && nvim daily/$(date +%Y-%m-%d).md'
alias oby='echo -e "\n---\n$(date +"%H:%M")\n" >> ~/Documents/Obsidian\ Vault/daily/$(date +%Y-%m-%d).md && pbpaste >> ~/Documents/Obsidian\ Vault/daily/$(date +%Y-%m-%d).md && echo "✅ クリップボードの内容をデイリーノートに追加しました"'

# nb (Notebook) aliases
export NB_DAILY_TEMPLATE="$HOME/memo/tamplete/daily.md"
export NB_TASK_TEMPLATE="$HOME/memo/tamplete/task.md"
alias nad='nb a ./daily/$(date +%Y-%m-%d).md  --template ${NB_DAILY_TEMPLATE}'
alias nat='nb a ./work/$(date +%Y-%m-%d).md  --template ${NB_TASK_TEMPLATE}'
naw() {
  if [[ -z "$1" ]]; then
    echo "Usage: naw <filename>"
    return 1
  fi
  nb a "./work/$1"
}

# mycli
alias mycli-prod='mycli --myclirc ~/dotfiles/mycli/myclirc.prod'
alias mycli-dev='mycli --myclirc ~/dotfiles/mycli/myclirc.dev'
alias mycli-local='mycli --myclirc ~/dotfiles/mycli/myclirc.local'

# direnv
alias env-local='export APP_ENV=local && direnv reload'
alias env-stg='export APP_ENV=stg && direnv reload'

y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
