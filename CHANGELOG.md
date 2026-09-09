# Changelog

## Unreleased

- Replaced the broad global skill collection with a usage-backed allowlist and fail-loud installation manifest.
- Adopted attributed local snapshots of HumanLayer's `show-me` and Lauren Tan's `unslop` skills.
- Added a catalog of every evaluated skill with upstream credit and per-repo installation commands for specialized work.
- Kept the proven global workflows from Parcha Skills, Matt Pocock, Northflank, Cloudflare, Vercel Labs, and `i-have-adhd`.
- Removed retired global skills across Skills CLI agents while keeping their sources in the catalog.
- Made `bootstrap.sh` additive and non-destructive: it never replaces an existing file without consent. Conflicts prompt `[y/N/a]` interactively, skip when run non-interactively, or overwrite with `--yolo`/`-y` (backups still kept). New files/symlinks are added silently.
- Let the Skills CLI do all agent wiring: `npx skills add --global` installs into Claude, Codex, and Hermes (and ~30 other agents) automatically, so the manual fan-out loop and Hermes `external_dirs` wiring were removed. Local skills install the same way (by repo path). The `asc-*` iOS skills (from the `asc` CLI, not `npx`) are mirrored into Codex and Hermes by a small dedicated step.
- Added `asc` (App Store Connect CLI) to the Brewfile; it ships the `asc-*` iOS skills (TestFlight, metadata, release).
- Bootstrap installs every owned skill under `ai/skills/*` and selected upstream skills from `ai/skills/global-sources.txt`.
- Added `ai/codex-config.toml` for Codex CLI model settings (gpt-5.2-codex + high reasoning).
- Updated bootstrap to preserve existing Codex config (machine-specific project trusts).

## 2026-01-20

- Removed bun from Brewfile.

## 2026-01-19

- Centralized AI commands and skills under `ai/`, added canonical `AGENTS.md`, and updated bootstrap symlinks for Codex/Claude/Cursor, inspired by https://github.com/steipete/agent-scripts.
- Added `/merge-pr` plus shared `/handoff`, `/pickup`, and `/raise` command templates with slash-command docs.
- Cleaned bootstrap links and ignored Codex system skills cache.

## 2026-01-16

- Expanded `zsh/.zshrc` with additional PATH/setup entries and updated global gitignore entries.
- Added the `/prd-interview` command and trimmed Claude instructions.

## 2025-12-10

- Added the `/create-prompt` command for generating prompt templates.

## 2025-11-26

- Added the baseline `claude/CLAUDE.md` instructions file.

## 2025-11-23

- Added Antigravity PATH setup to `zsh/.zshrc`.

## 2025-11-19

- Updated Claude guidance and switched the default editor from VS Code to Cursor.

## 2025-11-15

- Replaced the old design guide with the `frontend-design` skill.

## 2025-11-10

- Removed coding assistants from the Brewfile.

## 2025-11-09

- Ignored local Claude settings and documented AI CLI dependencies in the README.

## 2025-11-08

- Added comprehensive bootstrap/setup, privacy-focused git config, and expanded README/gitignore.

## 2024-06-11

- Removed ngrok domain configuration.

## 2023-12-06

- Added git push auto-setup remote configuration.

## 2023-11-29

- Initial dotfiles layout with `.env` template and bootstrap foundations.
