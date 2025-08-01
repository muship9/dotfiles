# ================================================================
# Programming Language Managers Configuration
# ================================================================

# Volta (Node.js version manager)
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# rbenv (Ruby version manager)
if command -v rbenv &> /dev/null; then
  export PATH="~/.rbenv/shims:/usr/local/bin:$PATH"
  eval "$(rbenv init -)"
fi

# nodenv (Node.js version manager - alternative to Volta)
if command -v nodenv &> /dev/null; then
  export PATH="$HOME/.nodenv/bin:$PATH"
  eval "$(nodenv init -)"
fi

# Go
if command -v go &> /dev/null; then
  export PATH="$PATH:$(go env GOPATH)/bin"
fi

# GVM (Go Version Manager)
if [[ -s "$HOME/.gvm/scripts/gvm" ]] && [[ -z "$GVM_INIT" ]]; then
  export GVM_INIT=1
  source "$HOME/.gvm/scripts/gvm"
fi

# Bun (JavaScript runtime and package manager)
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"