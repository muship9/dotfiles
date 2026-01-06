# ================================================================
# Custom Functions
# ================================================================

# Open current git repository in GitHub browser
function ogb() {
  # Checkif we're in a git repository
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Error: Not in a git repository"
    return 1
  fi

  # Get the remote URL
  local remote_url
  remote_url=$(git config --get remote.origin.url)

  if [[ -z "$remote_url" ]]; then
    echo "Error: No remote origin found"
    return 1
  fi

  # Convert SSH URL to HTTPS URL if needed
  # SSH format: git@github.com:user/repo.git
  # HTTPS format: https://github.com/user/repo.git
  local web_url
  if [[ "$remote_url" =~ ^git@github\.com:(.+)$ ]]; then
    # SSH format
    web_url="https://github.com/${match[1]}"
  elif [[ "$remote_url" =~ ^https://github\.com/(.+)$ ]]; then
    # HTTPS format
    web_url="$remote_url"
  else
    echo "Error: Not a GitHub repository or unsupported URL format"
    return 1
  fi

  # Remove .git suffix if present
  web_url="${web_url%.git}"

  echo "Opening: $web_url"
  open "$web_url"
}

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


function es() {
  local envs=("local" "stg")
  echo "Select APP_ENV:"
  select env in "${envs[@]}"; do
    if [[ -n "$env" ]]; then
      export APP_ENV="$env"
      direnv reload
      echo "✔ switched to $APP_ENV"
      break
    fi
  done
}

