# ================================================================
# Environment Files Configuration
# ================================================================

# Load dotfiles environment variables
if [[ -f "$HOME/dotfiles/.env" ]]; then
  set -a
  source "$HOME/dotfiles/.env"
  set +a
fi
