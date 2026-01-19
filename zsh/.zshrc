# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="robbyrussell"

# Plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# ===== PATH Configuration =====
export PATH="$HOME/.local/bin:$PATH"

# ===== Editor =====
export EDITOR="cursor"
export REACT_TERMINAL="iTerm.app"

# ===== Locale =====
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# ===== Version Managers =====

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
nvm use default --silent 2>/dev/null

# Rbenv (Ruby)
if command -v rbenv 1>/dev/null 2>&1; then
  eval "$(rbenv init - zsh)"
fi

# ===== Modern CLI Tools =====

# fzf - Fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# zoxide - Smart cd
if command -v zoxide 1>/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# bat - Better cat
export BAT_THEME="TwoDark"

# ===== Aliases =====
[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases

# ===== Environment Variables & Secrets =====
# Load local environment variables (API keys, etc.)
# This file is gitignored and machine-specific
[ -f ~/.env.local ] && source ~/.env.local

# Added by Antigravity
export PATH="/Users/chris/.antigravity/antigravity/bin:$PATH"

# Fastlane update_fastlane command needs this
export GEM_HOME=~/.gems
export PATH=$PATH:~/.gems/bin

# pnpm
export PNPM_HOME="/Users/chris/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# ClawdHub default install directory
alias hub="clawdhub --dir ~/.clawdbot/skills"
