#!/bin/bash
# Dotfiles Bootstrap Script
# Installs and configures development environment

set -e

DOTFILES_DIR="$HOME/repos/dotfiles"
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

echo "🚀 Starting dotfiles setup..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

# Backup existing files
backup_if_exists() {
  if [ -f "$1" ] || [ -d "$1" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$1" "$BACKUP_DIR/"
    print_warning "Backed up $1 to $BACKUP_DIR"
  fi
}

# Create symlink
create_symlink() {
  local source=$1
  local target=$2

  backup_if_exists "$target"
  ln -sf "$source" "$target"
  print_success "Linked $target"
}

# ===== GitHub CLI Authentication =====
if ! command -v gh &> /dev/null; then
  print_error "GitHub CLI (gh) not found. Installing via Homebrew first..."
  if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  brew install gh
fi

if ! gh auth status &> /dev/null; then
  echo "🔐 Authenticating with GitHub..."
  gh auth login
  print_success "GitHub authenticated"
else
  print_success "GitHub already authenticated"
fi

# ===== Install Homebrew =====
if ! command -v brew &> /dev/null; then
  echo "📦 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  print_success "Homebrew installed"
else
  print_success "Homebrew already installed"
fi

# ===== Install Brew Packages =====
echo "📦 Installing packages from Brewfile..."
cd "$DOTFILES_DIR"
brew bundle
print_success "Packages installed"

# ===== Install Oh My Zsh =====
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "🎨 Installing Oh My Zsh..."
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
echo "🔗 Creating symlinks..."

# Zsh
create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/zsh/.zsh_aliases" "$HOME/.zsh_aliases"

# Git
create_symlink "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
create_symlink "$DOTFILES_DIR/git/.gitignore_global" "$HOME/.gitignore_global"

# Claude
create_symlink "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
mkdir -p "$HOME/.claude/commands"
mkdir -p "$HOME/.claude/skills"
for cmd in "$DOTFILES_DIR/claude/commands"/*.md; do
  [ -f "$cmd" ] && create_symlink "$cmd" "$HOME/.claude/commands/$(basename "$cmd")"
done
for skill in "$DOTFILES_DIR/claude/skills"/*; do
  [ -d "$skill" ] && create_symlink "$skill" "$HOME/.claude/skills/$(basename "$skill")"
done

# ===== Environment Setup =====
if [ ! -f "$HOME/.env.local" ]; then
  echo "📝 Creating .env.local from template..."
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
  echo "📝 Configure Git user info:"

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
echo "✅ Dotfiles setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit ~/.env.local with your secrets"
echo "2. Restart your terminal or run: source ~/.zshrc"
echo "3. Optional: Configure GPG signing (see git/.gitconfig)"
echo ""

if [ -d "$BACKUP_DIR" ]; then
  echo "📦 Backups saved to: $BACKUP_DIR"
fi
