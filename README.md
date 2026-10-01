# Dotfiles

My personal dotfiles. Installs essential CLI tools, configures shell, git, and development workflows.

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

3. **Configure secrets and user info**

   ```bash
   # Git credentials (required for commits)
   cp ~/repos/dotfiles/git/.gitconfig.local.example ~/.gitconfig.local
   cursor ~/.gitconfig.local  # Add your name and email

   # Environment secrets (API keys, tokens, etc.)
   cursor ~/.env.local
   ```

### Is it Safe to Rerun?

**Yes.** The bootstrap script is **additive and non-destructive** by default:

- New files/symlinks are added silently; an existing file is **never replaced without your OK**
- When something would be overwritten, it prompts `[y/N/a]` (yes / skip / yes-to-all)
- Running non-interactively (piped/CI) **skips** any conflict instead of clobbering
- `--yolo` (or `-y`) overwrites conflicts without asking — existing files are still backed up first
- Backups go to `~/dotfiles-backup-YYYYMMDD-HHMMSS`
- Checks if tools are already installed before installing; prompts for git name/email only if unset

```bash
./bootstrap.sh          # additive: ask before replacing anything
./bootstrap.sh --yolo   # overwrite conflicts (backups still kept)
```

Rerun anytime to install missing packages and refresh symlinks.

### Considerations

- **GitHub auth required first** - Script uses `gh` CLI for operations
- **Existing configs backed up** - Your current .zshrc, .gitconfig, etc. are saved
- **Prompts for git identity** - Asks for name/email if not configured
- **Creates `~/.env.local` and `~/.gitconfig.local`** - Templates for secrets (gitignored)
- **GPG signing optional** - Uncomment in `~/.gitconfig.local` if you use it

### Global AI CLI Dependencies

These dotfiles rely on both the Claude Code CLI and the OpenAI Codex CLI being installed globally so that the companion IDEs/commands work everywhere on the system. `brew bundle` (run inside `bootstrap.sh`) handles this automatically via the `Brewfile`, but you can install or update them manually at any time:

```bash
brew tap anthropic-ai/claude
brew install claude-code

brew tap openai/codex
brew install codex-cli
```

The CLIs will then be available system-wide (e.g., `claude-code --help`, `codex --help`).

## Customization

Common changes you might want to make:

| What                       | Where              | How                                                          |
| -------------------------- | ------------------ | ------------------------------------------------------------ |
| **Add CLI aliases**        | `zsh/.zsh_aliases` | Edit file, add alias lines                                   |
| **Add brew packages**      | `Brewfile`         | Add `brew "package-name"`, run `brew bundle`                 |
| **Change git settings**    | `git/.gitconfig`   | Modify aliases, behavior (user info in `~/.gitconfig.local`) |
| **Update agent rules**     | `AGENTS.md`        | Edit shared instructions (Codex/Claude/Cursor)               |
| **Add skills**             | `chrisrodz/skills` | Separate repo; see its README and REFERENCES.md              |
| **Modify shell behavior**  | `zsh/.zshrc`       | Edit PATH, themes, plugins                                   |

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
- `trash` - Safe delete CLI
- `herdr` - Persistent, agent-aware terminal multiplexer

Launch or reattach with `herdr`; it manages its own server, so agent processes and
panes remain available across terminal sessions.

**Version Managers**

- `nvm` - Node.js version management
- Current Node.js LTS - Installed and selected automatically through NVM
- `uv` - Fast Python package installer & version manager
- `bun` - JS runtime for tools/scripts

**Development Apps**

- `cursor` - AI code editor
- `tailscale-app` - Mesh VPN client

**Mobile Development**

- `cocoapods` - Native iOS dependencies for `npx expo run:ios`
- Xcode plus one current iOS Simulator runtime - Installed separately through Apple

**Coding Agents**

- `pi` - Pi coding agent, installed globally from `@earendil-works/pi-coding-agent`

**Git & Security**

- `git` - Latest version
- `gpg` - For commit signing

### Shell Configuration

**Oh My Zsh** with plugins:

- `zsh-autosuggestions` - Command suggestions
- `zsh-syntax-highlighting` - Syntax highlighting

**40+ Aliases** including:

- Modern CLI shortcuts (`ls` -> `eza`, `cat` -> `bat`, `cd` -> `zoxide`)
- Git shortcuts (`gs`, `ga`, `gc`, `gp`, `gl`, `glog`)
- Python helpers (`venv`, `activate`, `pyclean`)
- Node shortcuts (`nr`, `nrd`, `nrb`)
- Utils (`mkcd`, `port`, `killport`, `serve`)

### Git Configuration

- **Privacy-first**: User info stored in `~/.gitconfig.local` (gitignored)
- Auto-setup remote on push
- GitHub credential helper via `gh` CLI
- Useful aliases (`lg`, `hist`, `unstage`)
- Optional GPG commit signing (configure in `~/.gitconfig.local`)
- Global ignores for Python/Node/macOS

**Setup**: Copy `git/.gitconfig.local.example` to `~/.gitconfig.local` and add your name/email

### Agent Instructions and Skills

- Canonical rules: `AGENTS.md` (shared by Claude, Codex, Cursor, Hermes); bootstrap links it to `~/.codex/AGENTS.md` and `~/.claude/CLAUDE.md`
- Skills: not managed here. My skills and a curated catalog of others' skills live in [chrisrodz/skills](https://github.com/chrisrodz/skills). Install with `npx skills add chrisrodz/skills --global`
- `asc-*` iOS skills ship with the `asc` brew CLI

### AI Coding Assistants

- `claude-code` - Global Claude Code CLI installed via Homebrew for Anthropic workflows
- `codex-cli` - Global OpenAI Codex CLI installed via Homebrew for Codex CLI tooling
- `hermes` - Nous Research Hermes agent

### Expo iOS Simulator

Install the latest stable Xcode from the Mac App Store, open it once to accept
its license and finish component installation, then install only the current iOS
Simulator runtime:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
xcodebuild -runFirstLaunch
xcodebuild -downloadPlatform iOS
```

Older simulator runtimes are optional and are not part of this setup.
