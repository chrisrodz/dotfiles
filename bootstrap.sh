#!/bin/bash
# Dotfiles Bootstrap Script
# Installs and configures development environment
# Works on macOS (Homebrew) and Linux/Ubuntu (apt)

set -e

DOTFILES_DIR="$HOME/repos/dotfiles"
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
OS="$(uname -s)"

# Conflict behavior:
#   default  - additive & non-destructive. New things are added silently;
#              anything that would REPLACE an existing file prompts you to
#              decide (or is skipped when running non-interactively).
#   --yolo   - overwrite anything in the way (existing files are backed up first).
YOLO=0
for arg in "$@"; do
  case "$arg" in
    --yolo|-y|--force) YOLO=1 ;;
    -h|--help)
      echo "Usage: ./bootstrap.sh [--yolo]"
      echo "  --yolo, -y   Overwrite conflicting files without asking (backs up first)."
      echo "  (default)    Additive: never replace an existing file without your OK."
      exit 0 ;;
  esac
done

echo "Starting dotfiles setup... (detected OS: $OS)"
[ "$YOLO" = "1" ] && echo "Running in --yolo mode: conflicts will be overwritten (with backup)."

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
  if [ -e "$1" ] || [ -L "$1" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$1" "$BACKUP_DIR/"
    print_warning "Backed up $1 to $BACKUP_DIR"
  fi
}

# Decide whether we may replace an existing target.
# Returns 0 = go ahead (caller should back up + replace), 1 = leave it alone.
# --yolo: always replace. Non-interactive: skip (stay additive). TTY: ask.
may_replace() {
  local target=$1
  if [ "$YOLO" = "1" ]; then
    return 0
  fi
  if [ ! -t 0 ]; then
    print_warning "Exists, left unchanged (rerun with --yolo to overwrite): $target"
    return 1
  fi
  local reply
  printf "%bREPLACE?%b %s already exists. Overwrite (backup kept)? [y/N/a=yes-to-all] " \
    "$YELLOW" "$NC" "$target" > /dev/tty
  read -r reply < /dev/tty
  case "$reply" in
    a|A) YOLO=1; return 0 ;;
    y|Y) return 0 ;;
    *)   print_warning "Skipped (left existing): $target"; return 1 ;;
  esac
}

# Create symlink. Additive & non-destructive: adds when absent, only replaces
# an existing different target with your consent (or --yolo).
create_symlink() {
  local source=$1
  local target=$2

  # Already the correct symlink? Nothing to do.
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    print_success "Already linked $target"
    return 0
  fi

  # Target occupied by something else (real file/dir or wrong symlink): ask.
  if [ -e "$target" ] || [ -L "$target" ]; then
    may_replace "$target" || return 0
    backup_if_exists "$target"
  fi

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

  # Homebrew installs NVM without creating its working directory or a Node runtime.
  export NVM_DIR="$HOME/.nvm"
  mkdir -p "$NVM_DIR"
  # shellcheck disable=SC1091
  . "$(brew --prefix nvm)/nvm.sh"
  if ! nvm version default &> /dev/null; then
    echo "Installing current Node.js LTS..."
    nvm install --lts
    nvm alias default 'lts/*'
  fi
  nvm use default --silent
  print_success "Node.js $(node --version) available via NVM"

  brew services start herdr
  print_success "Herdr service started"

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

# ===== Pi Coding Agent =====
if ! command -v pi &> /dev/null; then
  echo "Installing Pi coding agent..."
  npm install --global @earendil-works/pi-coding-agent
  print_success "Pi coding agent installed"
else
  print_success "Pi coding agent already installed"
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
  skill_failures=()

  # Remove skills that are now catalog-only. Their sources and per-repo install
  # commands remain in ai/skills-catalog.md.
  retired_skills=(
    agent-device agentmail baseline-ui brave-search building-native-ui
    create-cli create-design-md design-an-interface desloppify domain-modeling
    edit-article expo-api-routes expo-cicd-workflows expo-deployment expo-dev-client
    expo-tailwind-setup fixing-accessibility fixing-metadata fixing-motion-performance
    frontend-design frontend-skill git-guardrails-claude-code grilling hands-free
    impeccable improve-ui instruments-profiling interface-design last30days
    markdown-converter migrate-to-shoehorn nano-banana-pro native-app-performance
    native-data-fetching obsidian-vault openai-image-gen parable prd-to-issues
    prototype qa remotion-best-practices request-refactor-plan resend
    scaffold-exercises setup-pre-commit tdd ui-skills-root upgrading-expo use-dom
    vercel-optimize vercel-react-best-practices vercel-react-native-skills
    video-transcript-downloader workspace-audit
  )
  if ! npx skills remove --global -y "${retired_skills[@]}"; then
    skill_failures+=("remove catalog-only skills")
  fi

  # Install only the externally maintained skills proven useful across repos.
  # The manifest is the machine-readable source of truth. The catalog records
  # attribution and the larger per-repo library.
  while IFS='|' read -r skill_source skill_name; do
    case "$skill_source" in
      ''|'#'*) continue ;;
    esac
    if [ -z "$skill_name" ]; then
      skill_failures+=("invalid manifest entry: $skill_source")
      continue
    fi
    if ! npx skills add "$skill_source" --global --agent '*' --skill "$skill_name" --yes --full-depth </dev/null; then
      skill_failures+=("install $skill_source:$skill_name")
    fi
  done < "$DOTFILES_DIR/ai/skills/global-sources.txt"

  # Install owned and attributed snapshots from this repository.
  for local_skill in "$DOTFILES_DIR"/ai/skills/*/; do
    [ -d "$local_skill" ] || continue
    if ! npx skills add "${local_skill%/}" --global --agent '*' --yes; then
      skill_failures+=("install ${local_skill%/}")
    fi
  done

  if [ "${#skill_failures[@]}" -gt 0 ]; then
    print_error "Skill setup failed:"
    printf '  - %s\n' "${skill_failures[@]}"
    exit 1
  fi
  print_success "Curated global skills installed for all Skills CLI agents"
else
  print_error "npx not found; global skills were not installed"
  exit 1
fi

# ===== iOS skills (asc CLI) — mirror into Codex + Hermes =====
# npx-installed skills reach every agent via the Skills CLI. The asc-* iOS skills
# are different: the `asc` CLI registers them into ~/.agents/skills and Claude
# only, so mirror just those into Codex and Hermes (additive — never clobbers).
asc_synced=0
for asc_skill in "$HOME"/.agents/skills/asc-*/; do
  [ -d "$asc_skill" ] || continue
  name=$(basename "$asc_skill")
  for agent_skills in "$HOME/.codex/skills" "$HOME/.hermes/skills"; do
    [ -d "$agent_skills" ] || continue
    [ -e "$agent_skills/$name" ] || { ln -sf "$asc_skill" "$agent_skills/$name"; asc_synced=1; }
  done
done
[ "$asc_synced" = "1" ] && print_success "Mirrored asc-* iOS skills into Codex + Hermes"

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
  echo "5. Launch Tailscale, sign in, and approve its system extension when prompted"
else
  echo "3. Optional: Configure GPG signing (see git/.gitconfig)"
fi
echo ""

if [ -d "$BACKUP_DIR" ]; then
  echo "Backups saved to: $BACKUP_DIR"
fi
