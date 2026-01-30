#!/bin/bash
# Dotfiles Bootstrap Script
# Installs and configures development environment

set -e

DOTFILES_DIR="$HOME/repos/dotfiles"
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

echo "Starting dotfiles setup..."

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

# ===== GitHub CLI Authentication =====
if ! command -v gh &> /dev/null; then
  print_error "GitHub CLI (gh) not found. Installing via Homebrew first..."
  if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  brew install gh
fi

if ! gh auth status &> /dev/null; then
  echo "Authenticating with GitHub..."
  gh auth login
  print_success "GitHub authenticated"
else
  print_success "GitHub already authenticated"
fi

# ===== Install Homebrew =====
if ! command -v brew &> /dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  print_success "Homebrew installed"
else
  print_success "Homebrew already installed"
fi

# ===== Install Brew Packages =====
echo "Installing packages from Brewfile..."
cd "$DOTFILES_DIR"
brew bundle
print_success "Packages installed"

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

# ===== Symlink Dotfiles =====
echo "Creating symlinks..."

# Zsh
create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/zsh/.zsh_aliases" "$HOME/.zsh_aliases"

# Git
create_symlink "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
create_symlink "$DOTFILES_DIR/git/.gitignore_global" "$HOME/.gitignore_global"

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
  npx skills add --global -y chrisrodz/dotfiles@polishing-issues 2>/dev/null || true
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
echo "3. Optional: Configure GPG signing (see git/.gitconfig)"
echo ""

if [ -d "$BACKUP_DIR" ]; then
  echo "Backups saved to: $BACKUP_DIR"
fi
