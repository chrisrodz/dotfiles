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

Rerun anytime to install missing packages or skills and refresh symlinks.

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
| **Add slash commands**     | `ai/commands/`     | Add `.md` files with prompts                                 |
| **Add skills**             | `npx skills add`   | Install globally via Skills CLI                              |
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

Herdr runs as a per-user login service after bootstrap. Launch or reattach with
`herdr`; agent processes and panes remain available across terminal sessions.

**Version Managers**

- `nvm` - Node.js version management
- Current Node.js LTS - Installed and selected automatically through NVM
- `uv` - Fast Python package installer & version manager
- `bun` - JS runtime for tools/scripts

**Development Apps**

- `cursor` - AI code editor
- `tailscale-app` - Mesh VPN client

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

### Agent Instructions and Commands

- Canonical rules: `AGENTS.md` (shared by Claude, Codex, Cursor, Hermes)
- Pointer for Claude: `claude/CLAUDE.md`
- Codex config: `ai/codex-config.toml` (model settings, copied to `~/.codex/config.toml`)
- Commands: `ai/commands` (symlinked to `~/.codex/prompts`, `~/.claude/commands`, `~/.cursor/commands`)
- Skills: installed globally to `~/.agents/skills/` (cross-agent standard), then fanned out

Bootstrap wires the symlinks, installs global skills, and exposes them to every agent.

### How skills reach each agent

`npx skills add --global` installs each skill to `~/.agents/skills/` and the
Skills CLI wires it into **Claude, Codex, Hermes** (and ~30 other agents)
automatically — no per-agent config in this repo. Local skills under `ai/skills/`
install the same way (bootstrap passes their repo path).

Exception: the `asc-*` iOS skills ship with the `asc` CLI (not `npx`), which only
registers them into `~/.agents/skills/` and Claude. Bootstrap mirrors just those
into Codex and Hermes so they're available in all three.

### Global Skills (installed by bootstrap)

Grouped by domain — the canonical list lives in `bootstrap.sh`:

```bash
# Core utilities (steipete/agent-scripts)
npx skills add --global -y steipete/agent-scripts@video-transcript-downloader
npx skills add --global -y steipete/agent-scripts@brave-search
npx skills add --global -y steipete/agent-scripts@nano-banana-pro
npx skills add --global -y steipete/agent-scripts@openai-image-gen
npx skills add --global -y steipete/agent-scripts@create-cli
npx skills add --global -y steipete/agent-scripts@instruments-profiling
npx skills add --global -y steipete/agent-scripts@markdown-converter
npx skills add --global -y steipete/agent-scripts@native-app-performance

# Web & cloud stacks — React / Next.js / React Native (Vercel), Cloudflare
npx skills add --global -y vercel-labs/agent-skills@vercel-react-best-practices
npx skills add --global -y vercel-labs/agent-skills@vercel-react-native-skills
npx skills add --global -y vercel-labs/agent-skills@vercel-optimize
npx skills add --global -y cloudflare/skills@cloudflare
npx skills add --global -y cloudflare/skills@workers-best-practices
npx skills add --global -y cloudflare/skills@wrangler

# Mobile / native — Expo (iOS asc-* skills ship with the `asc` brew CLI)
npx skills add --global -y expo/skills@building-native-ui
npx skills add --global -y expo/skills@expo-api-routes
npx skills add --global -y expo/skills@expo-cicd-workflows
npx skills add --global -y expo/skills@expo-deployment
npx skills add --global -y expo/skills@expo-dev-client
npx skills add --global -y expo/skills@expo-tailwind-setup
npx skills add --global -y expo/skills@native-data-fetching
npx skills add --global -y expo/skills@upgrading-expo
npx skills add --global -y expo/skills@use-dom

# Design & frontend polish
npx skills add --global -y openai/skills@frontend-skill
npx skills add --global -y pbakaus/impeccable
npx skills add --global -y Dammyjay93/interface-design
npx skills add --global -y ibelick/ui-skills

# Integrations & media
npx skills add --global -y vercel-labs/agent-browser@agent-browser
npx skills add --global -y agentmail-to/agentmail-skills@agentmail
npx skills add --global -y resend/resend-skills@resend
npx skills add --global -y remotion-dev/skills@remotion-best-practices

# Research & async coding workflows
npx skills add --global -y mattpocock/skills
npx skills add --global -y mvanhorn/last30days-skill@last30days
```

Local skills with no public registry live in `ai/skills/` (`polishing-issues`);
bootstrap installs them via the Skills CLI from their repo path, so they reach
every agent just like registry skills.

To find and add more skills: `npx skills find <query>` then `npx skills add --global -y <owner/repo@skill>`

Useful Matt Pocock skills include `/grill-me`, `/grill-with-docs`, `/diagnose`, `/triage`, `/to-prd`, `/to-issues`, `/prd-to-plan`, `/request-refactor-plan`, `/improve-codebase-architecture`, `/qa`, and `/handoff`.

### AI Coding Assistants

- `claude-code` - Global Claude Code CLI installed via Homebrew for Anthropic workflows
- `codex-cli` - Global OpenAI Codex CLI installed via Homebrew for Codex CLI tooling
- `hermes` - Nous Research Hermes agent; the Skills CLI wires global skills into it directly

### Expo iOS Simulator

Install the latest stable Xcode from the Mac App Store, open it once to accept
its license and finish component installation, then install only the current iOS
Simulator runtime:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
xcodebuild -downloadPlatform iOS
```

Older simulator runtimes are optional and are not part of this setup.
