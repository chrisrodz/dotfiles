# Skill catalog

Thin record of agent skills evaluated or installed through these dotfiles.

Statuses:

- `global`: installed on every bootstrapped machine.
- `owned`: stored under `ai/skills/` and installed globally.
- `catalog`: available for a repo or one-off task, not installed globally.
- `retired`: previously global; kept here so it can be found again.

Install a catalog skill from the target repository without `--global`:

```bash
npx skills add <owner/repo> --skill <skill-name> -y
```

## Global baseline

The machine-readable external allowlist is [`skills/global-sources.txt`](skills/global-sources.txt). Local owned skills live under [`skills/`](skills/).

| Source and credit | License | Skills | Management |
| --- | --- | --- | --- |
| This repository | Repository license | `daily-note`, `polishing-issues` | owned |
| [HumanLayer](https://github.com/humanlayer/skills) | MIT | `show-me` | owned, adapted with attribution |
| [Lauren Tan / Cursor](https://github.com/cursor/plugins/tree/main/pstack) | MIT | `unslop` | owned, adapted with attribution |
| [Parcha-ai/parcha-skills](https://github.com/Parcha-ai/parcha-skills) | MIT | `autoqa`, `cascade`, `recall`, `recap`, `tether` | global, upstream |
| [Matt Pocock](https://github.com/mattpocock/skills) | MIT | `code-review`, `codebase-design`, `diagnosing-bugs`, `research`, `resolving-merge-conflicts` | global, upstream |
| [Northflank](https://github.com/northflank/skills) | upstream repository | `northflank` | global, upstream |
| [Cloudflare](https://github.com/cloudflare/skills) | Apache-2.0 | `cloudflare`, `workers-best-practices`, `wrangler` | global, upstream |
| [Vercel Labs](https://github.com/vercel-labs/agent-browser) | Apache-2.0 | `agent-browser` | global, upstream |
| [ayghri](https://github.com/ayghri/i-have-adhd) | MIT | `i-have-adhd` | global, upstream |

## Catalog for per-repo use

### Mobile and native

| Source and credit | Skills | Install in a repo |
| --- | --- | --- |
| [Expo](https://github.com/expo/skills) | `building-native-ui`, `expo-api-routes`, `expo-cicd-workflows`, `expo-deployment`, `expo-dev-client`, `expo-tailwind-setup`, `native-data-fetching`, `upgrading-expo`, `use-dom` | `npx skills add expo/skills --skill <name> -y` |
| [Callstack](https://github.com/callstack/agent-device) | `agent-device` | `npx skills add callstack/agent-device --skill agent-device -y` |
| App Store Connect CLI | `asc-*` | Installed by `asc`; keep repository-specific links local |

### React, frontend, and design

| Source and credit | Skills | Install in a repo |
| --- | --- | --- |
| [Vercel Labs](https://github.com/vercel-labs/agent-skills) | `vercel-react-best-practices`, `vercel-react-native-skills`, `vercel-optimize` | `npx skills add vercel-labs/agent-skills --skill <name> -y` |
| [OpenAI](https://github.com/openai/skills) | `frontend-skill` | `npx skills add openai/skills --skill frontend-skill -y` |
| [Peter Bakaus](https://github.com/pbakaus/impeccable) | `impeccable` | `npx skills add pbakaus/impeccable --skill impeccable -y` |
| [Dammyjay93](https://github.com/Dammyjay93/interface-design) | `interface-design` | `npx skills add Dammyjay93/interface-design --skill interface-design -y` |
| [Ibelick](https://github.com/ibelick/ui-skills) | `baseline-ui`, `create-design-md`, `fixing-accessibility`, `fixing-metadata`, `fixing-motion-performance`, `improve-ui`, `ui-skills-root` | `npx skills add ibelick/ui-skills --skill <name> -y` |

### Media, documents, and communication

| Source and credit | Skills | Install in a repo |
| --- | --- | --- |
| [Peter Steinberger](https://github.com/steipete/agent-scripts) | `video-transcript-downloader`, `brave-search`, `nano-banana-pro`, `openai-image-gen`, `create-cli`, `instruments-profiling`, `markdown-converter`, `native-app-performance` | `npx skills add steipete/agent-scripts --skill <name> -y` |
| [Remotion](https://github.com/remotion-dev/skills) | `remotion-best-practices` | `npx skills add remotion-dev/skills --skill remotion-best-practices -y` |
| [AgentMail](https://github.com/agentmail-to/agentmail-skills) | `agentmail` | `npx skills add agentmail-to/agentmail-skills --skill agentmail -y` |
| [Resend](https://github.com/resend/resend-skills) | `resend` | `npx skills add resend/resend-skills --skill resend -y` |
| [Michael Van Horn](https://github.com/mvanhorn/last30days-skill) | `last30days` | `npx skills add mvanhorn/last30days-skill --skill last30days -y` |

### Engineering workflows

Install any current Matt Pocock skill with:

```bash
npx skills add mattpocock/skills --skill <name> -y
```

Catalog-only current skills:

`ask-matt`, `domain-modeling`, `grill-with-docs`, `implement`, `improve-codebase-architecture`, `prototype`, `setup-matt-pocock-skills`, `tdd`, `to-spec`, `to-tickets`, `triage`, `wayfinder`, `wizard`, `grill-me`, `grilling`, `handoff`, `teach`, `to-questionnaire`, `wait-what`, `writing-for-agents`, `claude-handoff`, `implement-spec`, `loop-me`, `retro`, `setup-ts-deep-modules`, `writing-beats`, `writing-fragments`, `writing-shape`, `git-guardrails-claude-code`, `migrate-to-shoehorn`, `scaffold-exercises`, `setup-pre-commit`.

Historical names no longer offered by the current upstream listing:

`design-an-interface`, `edit-article`, `qa`, `request-refactor-plan`, `ubiquitous-language`, `writing-great-skills`.

### Parcha portable workflows

Install any optional workflow with:

```bash
npx skills add Parcha-ai/parcha-skills --skill <name> -y --full-depth
```

Catalog-only skills: `hands-free`, `parable`, `desloppify`.

The machine-local `codex-parable` variant also passed through this setup. Prefer the maintained `parable` package or record a new source before restoring it elsewhere.

## Retired global set

These names are removed by bootstrap when present. Their source remains above for future per-repo use.

`agent-device`, `agentmail`, `baseline-ui`, `brave-search`, `building-native-ui`, `create-cli`, `create-design-md`, `design-an-interface`, `desloppify`, `domain-modeling`, `edit-article`, `expo-api-routes`, `expo-cicd-workflows`, `expo-deployment`, `expo-dev-client`, `expo-tailwind-setup`, `fixing-accessibility`, `fixing-metadata`, `fixing-motion-performance`, `frontend-design`, `frontend-skill`, `git-guardrails-claude-code`, `grilling`, `hands-free`, `impeccable`, `improve-ui`, `instruments-profiling`, `interface-design`, `last30days`, `markdown-converter`, `migrate-to-shoehorn`, `nano-banana-pro`, `native-app-performance`, `native-data-fetching`, `obsidian-vault`, `openai-image-gen`, `parable`, `prd-to-issues`, `prototype`, `qa`, `remotion-best-practices`, `request-refactor-plan`, `resend`, `scaffold-exercises`, `setup-pre-commit`, `tdd`, `ui-skills-root`, `upgrading-expo`, `use-dom`, `vercel-optimize`, `vercel-react-best-practices`, `vercel-react-native-skills`, `video-transcript-downloader`, `workspace-audit`.
