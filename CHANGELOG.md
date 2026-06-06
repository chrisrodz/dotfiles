# Changelog

## Unreleased

- Made `bootstrap.sh` additive and non-destructive: it never replaces an existing file without consent. Conflicts prompt `[y/N/a]` interactively, skip when run non-interactively, or overwrite with `--yolo`/`-y` (backups still kept). New files/symlinks are added silently.
- Added `agent-device` (Callstack React Native device interaction) to the default mobile skills.
- Added default skills for the mobile/web stack: React + Next.js and React Native (Vercel Engineering), Vercel optimization, and Cloudflare (Workers, Wrangler, platform). Covers the new mobile app's stack out of the box.
- Wired global skills into all three coding agents: Claude (`~/.claude/skills`), Codex (`~/.codex/skills`), and Hermes (`~/.hermes/config.yaml` `external_dirs` + `AGENTS.md` synced into a managed block in `SOUL.md`).
- Reconciled `bootstrap.sh` to be the true source of truth: grouped the skill list by domain, removed dead refs that never installed (Obsidian pack, callstack `agent-device`), and added in-use skills (remotion, last30days).
- Added `asc` (App Store Connect CLI) to the Brewfile; it ships the `asc-*` iOS skills (TestFlight, metadata, release).
- Removed the bundled `ai/skills/last30days/` (~200 files); now installed from the `mvanhorn/last30days-skill` registry instead.
- Bootstrap now symlinks every local skill under `ai/skills/*` automatically (previously hardcoded to `polishing-issues`).
- Added Matt Pocock's skills to bootstrap for async coding workflows like `/grill-me` and `/grill-with-docs`.
- Migrated skills to global installation via `npx skills add --global`. Skills now installed from public registries instead of being bundled in repo.
- Removed `ai/skills/` directory. Skills are now managed by the Skills CLI.
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
