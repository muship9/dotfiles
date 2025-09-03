# ================================================================
# Custom Functions
# ================================================================

# Enhanced history search with fzf (fallback to built-in if fzf is missing)
if command -v fzf &> /dev/null; then
  function select-history() {
    local selected
    selected=$(history -n -r 1 | fzf --no-sort +m --query "$LBUFFER" --prompt="History > ")
    if [[ -n "$selected" ]]; then
      BUFFER="$selected"
      CURSOR=${#BUFFER}
    fi
    zle reset-prompt
  }
  zle -N select-history
  bindkey '^r' select-history
else
  # Fallback to incremental search
  bindkey '^r' history-incremental-search-backward
fi
