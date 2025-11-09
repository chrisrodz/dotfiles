# Dotfiles

Personal macOS development environment for Python and TypeScript. Installs essential CLI tools, configures shell, git, and development workflows.

```bash
gh repo clone chrisrodz/dotfiles ~/repos/dotfiles
cd ~/repos/dotfiles
./bootstrap.sh
```

## Installation & Setup

### On a New Machine

1. **Authenticate with GitHub**
   ```bash
   gh auth login
   ```

2. **Clone and run bootstrap**
   ```bash
   gh repo clone chrisrodz/dotfiles ~/repos/dotfiles
   cd ~/repos/dotfiles
   ./bootstrap.sh
   ```

3. **Configure secrets**
   ```bash
   code ~/.env.local
   # Add your API keys, tokens, etc.
   ```

### Is it Safe to Rerun?

**Yes.** The bootstrap script:
- Creates timestamped backups (`~/dotfiles-backup-YYYYMMDD-HHMMSS`) before overwriting any files
- Checks if tools are already installed before installing
- Prompts for git user.name and email (skip if already set)

Rerun anytime to update symlinks or install missing packages.

### Considerations

- **GitHub auth required first** - Script uses `gh` CLI for operations
- **Existing configs backed up** - Your current .zshrc, .gitconfig, etc. are saved
- **Prompts for git identity** - Asks for name/email if not configured
- **Creates ~/.env.local** - Template for machine-specific secrets (gitignored)
- **GPG signing optional** - Uncomment in `git/.gitconfig` if you use it

## Customization

Common changes you might want to make:

| What | Where | How |
|------|-------|-----|
| **Add CLI aliases** | `zsh/.zsh_aliases` | Edit file, add alias lines |
| **Add brew packages** | `Brewfile` | Add `brew "package-name"`, run `brew bundle` |
| **Change git settings** | `git/.gitconfig` | Modify aliases, signing, behavior |
| **Update Claude settings** | `claude/CLAUDE.md` | Edit global instructions |
| **Add slash commands** | `claude/commands/` | Add `.md` files with prompts |
| **Modify shell behavior** | `zsh/.zshrc` | Edit PATH, themes, plugins |

### Updating Other Machines

After making changes:
```bash
cd ~/repos/dotfiles
# Commit your changes with git/gh, then on other machines:
gh repo sync
./bootstrap.sh  # Refresh symlinks
```

## What Gets Installed

### CLI Tools (via Brewfile)

**Search & Navigation**
- `fzf` - Fuzzy finder for files/history
- `ripgrep` - Faster grep
- `fd` - Faster find
- `zoxide` - Smart cd with frecency

**Modern Replacements**
- `bat` - Better cat with syntax highlighting
- `eza` - Better ls with git status/icons
- `tldr` - Simplified man pages

**Dev Tools**
- `jq` / `yq` - JSON/YAML processors
- `httpie` - User-friendly HTTP client
- `gh` - GitHub CLI

**System Utils**
- `htop` - Process viewer
- `tree` - Directory visualization

**Version Managers**
- `nvm` - Node.js version management
- `uv` - Fast Python package installer & version manager

**Git & Security**
- `git` - Latest version
- `gpg` - For commit signing

### Shell Configuration

**Oh My Zsh** with plugins:
- `zsh-autosuggestions` - Command suggestions
- `zsh-syntax-highlighting` - Syntax highlighting

**40+ Aliases** including:
- Modern CLI shortcuts (`ls` → `eza`, `cat` → `bat`, `cd` → `zoxide`)
- Git shortcuts (`gs`, `ga`, `gc`, `gp`, `gl`, `glog`)
- Python helpers (`venv`, `activate`, `pyclean`)
- Node shortcuts (`nr`, `nrd`, `nrb`)
- Utils (`mkcd`, `port`, `killport`, `serve`)

### Git Configuration

- Auto-setup remote on push
- GitHub credential helper via `gh` CLI
- Useful aliases (`lg`, `hist`, `unstage`)
- Optional GPG commit signing
- Global ignores for Python/Node/macOS

### Claude Settings

- Global instructions (`CLAUDE.md`)
- Custom slash commands
- Custom skills

Symlinked to `~/.claude/` for use with Claude Code.
