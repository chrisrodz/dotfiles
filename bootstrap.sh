#!/bin/bash
# Dotfiles Bootstrap Script
# Installs and configures development environment
# Works on macOS (Homebrew) and Linux/Ubuntu (apt)

set -e

DOTFILES_DIR="$HOME/repos/dotfiles"
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
OS="$(uname -s)"

echo "Starting dotfiles setup... (detected OS: $OS)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_success() {
  echo -e "${GREEN}OK${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}WARN${NC} $1"
}

print_error() {
  echo -e "${RED}ERR${NC} $1"
}

# Backup existing files
backup_if_exists() {
  if [ -f "$1" ] || [ -d "$1" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$1" "$BACKUP_DIR/"
    print_warning "Backed up $1 to $BACKUP_DIR"
  fi
}

# Create symlink (idempotent - skips if already correct)
create_symlink() {
  local source=$1
  local target=$2

  # If target is already a symlink pointing to the correct source, skip
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    print_success "Already linked $target"
    return 0
  fi

  backup_if_exists "$target"
  ln -sf "$source" "$target"
  print_success "Linked $target"
}

# ===== Package Installation =====
if [ "$OS" = "Darwin" ]; then
  # macOS: Install Homebrew + packages
  if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    print_success "Homebrew installed"
  else
    print_success "Homebrew already installed"
  fi

  echo "Installing packages from Brewfile..."
  cd "$DOTFILES_DIR"
  brew bundle
  print_success "Brew packages installed"

elif [ "$OS" = "Linux" ]; then
  # Linux: Install packages via apt
  echo "Installing apt packages..."
  sudo apt update
  grep -v '^#' "$DOTFILES_DIR/packages.apt" | grep -v '^$' | xargs sudo apt install -y
  print_success "apt packages installed"

  # Install tools not in apt repos (or outdated there)

  # GitHub CLI
  if ! command -v gh &> /dev/null; then
    echo "Installing GitHub CLI..."
    (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
      && sudo mkdir -p -m 755 /etc/apt/keyrings \
      && out=$(mktemp) && wget -nv -O"$out" https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      && cat "$out" | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
      && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
      && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
      && sudo apt update \
      && sudo apt install gh -y
    print_success "GitHub CLI installed"
  else
    print_success "GitHub CLI already installed"
  fi

  # eza (modern ls)
  if ! command -v eza &> /dev/null; then
    echo "Installing eza..."
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg
    sudo apt update
    sudo apt install -y eza
    print_success "eza installed"
  else
    print_success "eza already installed"
  fi

  # zoxide (smart cd)
  if ! command -v zoxide &> /dev/null; then
    echo "Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    print_success "zoxide installed"
  else
    print_success "zoxide already installed"
  fi

  # yq (YAML processor)
  if ! command -v yq &> /dev/null; then
    echo "Installing yq..."
    YQ_VERSION=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | grep tag_name | cut -d '"' -f 4)
    sudo wget -qO /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64"
    sudo chmod +x /usr/local/bin/yq
    print_success "yq installed"
  else
    print_success "yq already installed"
  fi

  # uv (Python package manager)
  if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    print_success "uv installed"
  else
    print_success "uv already installed"
  fi

  # tldr
  if ! command -v tldr &> /dev/null; then
    echo "Installing tldr..."
    sudo apt install -y tldr 2>/dev/null || pip3 install tldr 2>/dev/null || true
    print_success "tldr installed"
  else
    print_success "tldr already installed"
  fi
fi

# ===== GitHub CLI Authentication =====
if ! command -v gh &> /dev/null; then
  print_error "GitHub CLI (gh) not found after package installation"
  exit 1
fi

if ! gh auth status &> /dev/null; then
  echo "Authenticating with GitHub..."
  gh auth login
  print_success "GitHub authenticated"
else
  print_success "GitHub already authenticated"
fi

# ===== Install Oh My Zsh =====
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  print_success "Oh My Zsh installed"
else
  print_success "Oh My Zsh already installed"
fi

# Install zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  gh repo clone zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  print_success "zsh-autosuggestions installed"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  gh repo clone zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  print_success "zsh-syntax-highlighting installed"
fi

# ===== NVM (Linux only - macOS gets it from Homebrew) =====
if [ "$OS" = "Linux" ] && [ ! -d "$HOME/.nvm" ]; then
  echo "Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  print_success "NVM installed"
fi

# ===== Set default shell to zsh (Linux only) =====
if [ "$OS" = "Linux" ]; then
  CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)
  ZSH_PATH=$(which zsh)
  if [ "$CURRENT_SHELL" != "$ZSH_PATH" ]; then
    echo "Setting default shell to zsh..."
    chsh -s "$ZSH_PATH"
    print_success "Default shell set to zsh"
  else
    print_success "Default shell already zsh"
  fi
fi

# ===== Symlink Dotfiles =====
echo "Creating symlinks..."

# Zsh
create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/zsh/.zsh_aliases" "$HOME/.zsh_aliases"
if [ "$OS" = "Darwin" ]; then
  create_symlink "$DOTFILES_DIR/zsh/.zshrc.darwin" "$HOME/.zshrc.darwin"
elif [ "$OS" = "Linux" ]; then
  create_symlink "$DOTFILES_DIR/zsh/.zshrc.linux" "$HOME/.zshrc.linux"
fi

# Git
create_symlink "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
create_symlink "$DOTFILES_DIR/git/.gitignore_global" "$HOME/.gitignore_global"

# Tmux
create_symlink "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

# Claude
mkdir -p "$HOME/.claude"
create_symlink "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
create_symlink "$DOTFILES_DIR/ai/commands" "$HOME/.claude/commands"

# Codex
mkdir -p "$HOME/.codex"
create_symlink "$DOTFILES_DIR/AGENTS.md" "$HOME/.codex/AGENTS.md"
create_symlink "$DOTFILES_DIR/ai/commands" "$HOME/.codex/prompts"
# Merge codex config (preserve machine-specific project trusts)
if [ -f "$HOME/.codex/config.toml" ]; then
  # Keep existing config, just ensure model settings are current
  print_success "Codex config exists (preserving project trusts)"
else
  cp "$DOTFILES_DIR/ai/codex-config.toml" "$HOME/.codex/config.toml"
  print_success "Created Codex config"
fi

# Cursor
mkdir -p "$HOME/.cursor"
create_symlink "$DOTFILES_DIR/ai/commands" "$HOME/.cursor/commands"

# Shared scripts
mkdir -p "$HOME/.local/bin"
for script in committer nanobanana; do
  create_symlink "$DOTFILES_DIR/ai/scripts/$script" "$HOME/.local/bin/$script"
done

# ===== Install Global Skills =====
echo "Installing global agent skills..."
if command -v npx &> /dev/null; then
  # Core skills from public registries (installed to ~/.agents/skills/)
  # From steipete/agent-scripts
  npx skills add --global -y steipete/agent-scripts@video-transcript-downloader 2>/dev/null || true
  npx skills add --global -y steipete/agent-scripts@brave-search 2>/dev/null || true
  npx skills add --global -y steipete/agent-scripts@nano-banana-pro 2>/dev/null || true
  npx skills add --global -y steipete/agent-scripts@openai-image-gen 2>/dev/null || true
  npx skills add --global -y steipete/agent-scripts@create-cli 2>/dev/null || true
  npx skills add --global -y steipete/agent-scripts@frontend-design 2>/dev/null || true
  npx skills add --global -y steipete/agent-scripts@instruments-profiling 2>/dev/null || true
  npx skills add --global -y steipete/agent-scripts@markdown-converter 2>/dev/null || true
  npx skills add --global -y steipete/agent-scripts@native-app-performance 2>/dev/null || true
  # From other registries
  npx skills add --global -y vercel-labs/agent-browser@agent-browser 2>/dev/null || true
  # Local skills (not in any public registry) - symlinked from this repo
  mkdir -p "$HOME/.agents/skills"
  mkdir -p "$HOME/.claude/skills"
  create_symlink "$DOTFILES_DIR/ai/skills/polishing-issues" "$HOME/.agents/skills/polishing-issues"
  create_symlink "$HOME/.agents/skills/polishing-issues" "$HOME/.claude/skills/polishing-issues"
  npx skills add --global -y agentmail-to/agentmail-skills@agentmail 2>/dev/null || true
  # Resend (email sending platform) - umbrella skill routes to send-email/resend-inbound
  npx skills add --global -y resend/resend-skills@resend 2>/dev/null || true
  # Expo (React Native framework) - official skills from expo/skills
  npx skills add --global -y expo/skills@building-native-ui 2>/dev/null || true
  npx skills add --global -y expo/skills@expo-api-routes 2>/dev/null || true
  npx skills add --global -y expo/skills@expo-cicd-workflows 2>/dev/null || true
  npx skills add --global -y expo/skills@expo-deployment 2>/dev/null || true
  npx skills add --global -y expo/skills@expo-dev-client 2>/dev/null || true
  npx skills add --global -y expo/skills@expo-tailwind-setup 2>/dev/null || true
  npx skills add --global -y expo/skills@native-data-fetching 2>/dev/null || true
  npx skills add --global -y expo/skills@upgrading-expo 2>/dev/null || true
  npx skills add --global -y expo/skills@use-dom 2>/dev/null || true
  # Callstack - React Native device interaction
  npx skills add --global -y callstackincubator/agent-device@agent-device 2>/dev/null || true
  # Obsidian - vault management, markdown, bases, canvas, defuddle
  npx skills add --global -y kepano/obsidian-skills@obsidian-cli 2>/dev/null || true
  npx skills add --global -y kepano/obsidian-skills@obsidian-markdown 2>/dev/null || true
  npx skills add --global -y kepano/obsidian-skills@obsidian-bases 2>/dev/null || true
  npx skills add --global -y kepano/obsidian-skills@json-canvas 2>/dev/null || true
  npx skills add --global -y kepano/obsidian-skills@defuddle 2>/dev/null || true
  # UI Design Skills (frontend polish, accessibility, design systems)
  npx skills add --global -y pbakaus/impeccable 2>/dev/null || true
  npx skills add --global -y Dammyjay93/interface-design 2>/dev/null || true
  npx skills add --global -y ibelick/ui-skills 2>/dev/null || true
  # Ensure all skills are symlinked into Claude Code
  mkdir -p "$HOME/.claude/skills"
  for skill_dir in "$HOME/.agents/skills"/*/; do
    skill_name=$(basename "$skill_dir")
    if [ ! -e "$HOME/.claude/skills/$skill_name" ]; then
      ln -sf "$skill_dir" "$HOME/.claude/skills/$skill_name"
      print_success "Linked skill $skill_name to Claude Code"
    fi
  done
  print_success "Global skills installed to ~/.agents/skills/"
else
  print_warning "npx not found, skipping skills installation"
fi

# ===== Environment Setup =====
if [ ! -f "$HOME/.env.local" ]; then
  echo "Creating .env.local from template..."
  cp "$DOTFILES_DIR/.env.local.example" "$HOME/.env.local"
  print_warning "Edit ~/.env.local with your secrets and API keys"
else
  print_success ".env.local already exists"
fi

# ===== Configure Git User =====
CURRENT_NAME=$(git config --global user.name 2>/dev/null)
CURRENT_EMAIL=$(git config --global user.email 2>/dev/null)

if [ -n "$CURRENT_NAME" ] && [ -n "$CURRENT_EMAIL" ]; then
  print_success "Git already configured: $CURRENT_NAME <$CURRENT_EMAIL>"
else
  echo ""
  echo "Configure Git user info:"

  if [ -z "$CURRENT_NAME" ]; then
    read -p "Git name: " git_name
    [ -n "$git_name" ] && git config --global user.name "$git_name" && print_success "Git name set"
  fi

  if [ -z "$CURRENT_EMAIL" ]; then
    read -p "Git email: " git_email
    [ -n "$git_email" ] && git config --global user.email "$git_email" && print_success "Git email set"
  fi
fi

# ===== Post-install Instructions =====
echo ""
echo "Dotfiles setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit ~/.env.local with your secrets"
echo "2. Restart your terminal or run: source ~/.zshrc"
if [ "$OS" = "Darwin" ]; then
  echo "3. Optional: Set editor override in ~/.gitconfig.local (editor = cursor --wait)"
  echo "4. Optional: Configure GPG signing (see git/.gitconfig)"
else
  echo "3. Optional: Configure GPG signing (see git/.gitconfig)"
fi
echo ""

if [ -d "$BACKUP_DIR" ]; then
  echo "Backups saved to: $BACKUP_DIR"
fi
