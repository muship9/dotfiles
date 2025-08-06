# ================================================================
# Editor Configuration
# ================================================================

# Default editor setup with neovim-remote support
if [[ -n "$NVIM" ]]; then
    # Inside Neovim terminal - use neovim-remote
    alias nvim="nvr -cc split --remote-tab-wait +'set bufhidden=wipe'"
    alias vim="nvr -cc split --remote-tab-wait +'set bufhidden=wipe'"
    export VISUAL="nvr -cc split --remote-tab-wait +'set bufhidden=wipe'"
    export EDITOR="nvr -cc split --remote-tab-wait +'set bufhidden=wipe'"
    export GIT_EDITOR="nvr -cc split --remote-tab-wait +'set bufhidden=wipe'"
else
    # Normal shell - use neovim directly
    export VISUAL="nvim"
    export EDITOR="nvim"
    export GIT_EDITOR="nvim"
fi