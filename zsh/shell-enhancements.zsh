# ================================================================
# Shell Enhancements Configuration
# ================================================================

# History settings for multiline commands
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks from history
setopt HIST_IGNORE_ALL_DUPS      # Remove duplicates from history
setopt HIST_SAVE_NO_DUPS         # Don't save duplicates to history file
setopt INC_APPEND_HISTORY        # Add commands to history immediately
setopt EXTENDED_HISTORY          # Add timestamps to history
HISTSIZE=50000                   # Number of commands in memory
SAVEHIST=50000                   # Number of commands in history file

# Zsh plugins (installed via Homebrew)
if command -v brew &> /dev/null; then
  local brew_prefix
  brew_prefix="$(brew --prefix 2>/dev/null)"
  if [[ -f "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  fi
  if [[ -f "$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  fi
fi

# Starship prompt
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

# fzf key bindings and completion
if command -v fzf &> /dev/null; then
  # Expand the fzf window for history search and keep long commands visible.
  if [[ -z ${FZF_TMUX_HEIGHT-} ]]; then
    export FZF_TMUX_HEIGHT=80%
  fi
  if [[ -z ${FZF_CTRL_R_OPTS-} ]]; then
    export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window=down:55%:wrap"
  fi
  source <(fzf --zsh)
  
  # Custom fzf history widget that handles multiline commands
  fzf-history-widget-multiline() {
    local selected num
    setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
    selected=( $(fc -rl 1 | perl -ne 'print if !$seen{(/^\s*[0-9]+\**\s+(.*)/, $1)}++' |
      FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort,ctrl-z:ignore $FZF_CTRL_R_OPTS" $(__fzfcmd) +m) )
    local ret=$?
    if [ -n "$selected" ]; then
      num=$selected[1]
      if [ -n "$num" ]; then
        zle vi-fetch-history -n $num
        # Replace literal \n with actual newlines
        BUFFER=$(echo $BUFFER | sed 's/\\n/\n/g')
      fi
    fi
    zle reset-prompt
    return $ret
  }
  zle     -N   fzf-history-widget-multiline
  bindkey '^R' fzf-history-widget-multiline
fi

# direnv for directory-specific environment variables
if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi
