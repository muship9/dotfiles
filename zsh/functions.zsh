# ================================================================
# Custom Functions
# ================================================================

# Enhanced history search with fzf
function select-history() {
  BUFFER=$(history -n -r 1 | fzf --no-sort +m --query "$LBUFFER" --prompt="History > ")
  CURSOR=$#BUFFER
  zle reset-prompt
}
zle -N select-history
bindkey '^r' select-history