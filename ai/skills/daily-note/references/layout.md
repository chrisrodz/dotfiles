# Daily-note layout — "Variant A" (callout dashboard)

Single source of truth for how `daily-note` renders the Obsidian daily note in both
its CLOSE and OPEN phases. Read this file before writing and render exactly this
structure. The classification engine (which item goes to Doing / Done / Pending /
Info) lives in [classify-and-write.md](classify-and-write.md); this file governs
**rendering + write model only**. Substitute `{{TOKENS}}` from [config.md](config.md).

---

## Core principle — the agent owns the callouts

The user does **not** hand-edit callouts (the raw `>`-prefixed syntax is tedious to
maintain manually). Therefore:

- **Managed callout blocks are agent-owned and re-rendered wholesale from live data on every run.** Do not attempt surgical line-edits inside a callout. Rebuild the block from the consolidated candidate list (tracker status, PR state, CI, reviews — all re-fetched that run).
- Running the skill again mid-day is **idempotent and safe**: it re-pulls current state and re-renders the managed blocks. This is the supported way to "refresh" statuses through the workday.
- Issue/PR keys (matching `{{ISSUE_KEY_REGEX}}`, or `repo#N`) always appear in callout titles/bodies, so the whole-note key-set extraction for de-dup still works.

### Ownership map

| Region | Owner | Re-rendered each run? |
|---|---|---|
| `# title` + frontmatter | shared (frontmatter fields filled by whichever phase runs) | frontmatter yes, title no |
| `> [!todo] ▶ Right Now` | OPEN writes; CLOSE refreshes statuses | yes |
| `> [!warning] ⚠️ Watch today` | OPEN; CLOSE refreshes | yes (omit if nothing to watch) |
| `> [!example]- 📅 Schedule` | OPEN | yes |
| `> [!check]- 📊 Quick Log` | **USER-OWNED** — never overwrite contents | no |
| `## 🔨 Doing` callouts | OPEN builds; CLOSE promotes completed → Done | yes |
| `## ✅ Done` callouts | CLOSE fills bulk; OPEN adds overnight auto-resolves | yes |
| `## 📋 Pending` callouts | both; rewritten in full each run | yes |
| `## ℹ️ Context & meeting prep` callouts | OPEN writes prep; CLOSE appends `**✅ Recap:**` | yes |
| `> [!tip] 🌙 EOD Compound` | CLOSE only — OPEN never touches | filled once; user values preserved |
| `> [!note] 📝 Notes` (optional) | **USER-OWNED** escape hatch — preserve if present | no |

If the user wants a durable hand-written note, it goes in Quick Log or an optional
`> [!note] 📝 Notes` callout — both preserved verbatim across runs. Everything else is
regenerated.

---

## Status-badge vocabulary

Lead every Doing ticket and every Right-Now line with one glyph so state is visible
without reading the sentence:

| Badge | Meaning |
|---|---|
| `🚫` | Blocked — needs an unblock action |
| `⏳` | In review / awaiting my action (approve, merge, or someone else's review) |
| `🔵` | Actively doing / not yet in review |
| `💤` | Stale (2+ days no progress) |
| `⏰` | Has a hard due date |

Inline uncertainty markers stay inline (independent of badge):
`⚠️ inferred`, `⚠️ status unclear — last activity: …`, `_(stale Nd)_`, `_proposed: <section>_`.

Callout-type → colour → meaning (this is what solves "everything blends together"):

| Callout | Colour | Used for |
|---|---|---|
| `[!todo]` | green | Right Now band (actionable) |
| `[!warning]` | yellow | Watch today (risks/conflicts) |
| `[!example]` | purple | Schedule |
| `[!check]` | green | Quick Log |
| `[!abstract]` | blue-grey | each Doing ticket |
| `[!success]` | green | Done groups |
| `[!question]` | blue | Pending follow-ups |
| `[!danger]` | red | Pending stale carry-overs |
| `[!info]` | blue | Context / meeting prep |
| `[!tip]` | green | EOD Compound |

`-` after the type (e.g. `[!info]-`) makes the callout **collapsed by default** — the
core fatigue-reduction move. Collapse: Schedule, Quick Log, every Doing ticket, Done
groups, Pending groups, every meeting-prep block. Keep **expanded** (no `-`): Right
Now, Watch, EOD Compound.

---

## Canonical structure

```markdown
---
date: YYYY-MM-DD
weekday: Weekday
mit: <one-line MIT, no links>
capacity: <light day | full day | meeting-heavy (N)>
focus_window: <HH:MM–HH:MM {{TZ_LABEL}} or "none">
tags:
  - daily
---

# YYYY-MM-DD — Weekday

> [!todo] ▶ Right Now
> **🎯 MIT** — <MIT with links>
> **⏳ Awaiting my action** — <PRs needing my approve/merge, comma-sep with links>
> **🚫 Needs unblock** — <blocked item(s) + where/when to raise>
> **🕐 Next up** — <next meeting today + its single most important action>

> [!warning] ⚠️ Watch today
> <scheduling conflict or time-sensitive risk + the plan to handle it>

> [!example]- 📅 Schedule — N meetings<, cluster note>
> | Time ({{TZ_LABEL}}) | Meeting | Who / note |
> |---|---|---|
> | HH:MM | … | … |

> [!check]- 📊 Quick Log
> - [ ] Workout
> - [ ] House progress
> - [ ] Apt rental progress
> - _Contesta Chris_

---

## 🔨 Doing

> [!abstract]- <badge> <KEY> · <short title> — <status phrase>
> <primary PR/ticket link line + state>
> <next action / blocker, inline markers>
> - source: <only when 2+ sources merged — one sub-line each>

## ✅ Done

> [!success]- Shipped & merged (N)
> - **<KEY>** — <title> · [<repo#N>](url) merged HH:MM → Done HH:MM<, brief>

> [!success]- Reviews submitted today (N PRs)
> - [<repo#N>](url) — <title> · <merged | commented | closed>

## 📋 Pending

> [!question]- Follow-ups — consider promoting to Doing or ticketing
> - [ ] <item> — <trigger / source> <⏰ due … | ⚠️ inferred>

> [!danger]- 💤 Stale carry-overs — escalate or drop
> - [ ] <KEY> — <title> · <state> _(stale Nd)_ <⏰ due …>

## ℹ️ Context & meeting prep

> [!info]- 🌅 Overnight scan — <one-line gist>
> <2–4 lines of overnight signal>

> [!info]- 🕐 HH:MM <Meeting> — <attendees>
> - <prep bullet>
> - <prep bullet>
> **✅ Recap:** <filled by CLOSE — decisions + my action items, 3–4 bullets max>

> [!info]- 📌 FYIs
> - <fyi>

---

> [!tip] 🌙 EOD Compound
> **Win** — <…>
> **Learning** — <…>
> **Tomorrow's MIT** — <…>
```

---

## Deriving the top bands (the only *new* synthesis vs. the raw buckets)

The Right Now / Watch / Schedule bands are **not new data** — they are a re-projection
of items the classification engine already produced. Derive, don't re-gather:

**Right Now** (always present, expanded). One line per non-empty field; omit any field
with no content (never show an empty "Awaiting" line):
- `🎯 MIT` — the MIT line verbatim (with links).
- `⏳ Awaiting my action` — Doing items badged `⏳` whose next action is *mine* (approve / merge / my review). Comma-separated PR links. In CLOSE, refresh to current mergeability.
- `🚫 Needs unblock` — Doing items badged `🚫`, each with where/when to raise it (e.g. "raise 14:30 Jose").
- `🕐 Next up` — the next meeting *after the current time* (from Schedule) + its single most important prep action. In CLOSE, set to tomorrow's first meeting if known, else omit the line.

**Watch today** (conditional — omit the whole callout if empty):
- Any scheduling conflict (overlapping accepted meetings) + the one-line plan to handle it.
- Any same-day hard deadline or time-sensitive risk.

**Schedule** (collapsed; omit if no work meetings):
- One table row per work meeting, sorted by start. Mark conflicts with `⚠️` in the Who/note column. Header line includes count and any cluster note (e.g. "clustered 13:00–16:15").

---

## Rendering rules (apply in both phases)

1. **Re-render managed blocks; never surgically patch a callout.** Rebuild each managed callout from the candidate list every run.
2. **One item, one place.** A given `KEY` appears in exactly one of Doing / Done / Pending (Right Now references it but does not re-state it as a separate work item). Context/Info may mention a key in prose without it counting as a second entry.
3. **Collapse detail, surface action.** Doing tickets, Done groups, Pending groups, Schedule, and meeting prep are collapsed (`-`). Right Now, Watch, and EOD Compound stay expanded.
4. **Preserve user-owned regions byte-for-byte:** Quick Log contents, any `> [!note] 📝 Notes` callout, and non-empty EOD Compound field values. The OPEN phase never touches the EOD Compound callout at all.
5. **Omit empty callouts.** No empty Watch, no empty Schedule, no empty Done/Pending groups. If Pending is wholly empty, render `> [!question] 📋 Pending\n> _Nothing to triage._` so the structure survives for tomorrow.
6. **Links are mandatory** for every PR and tracker issue: `[repo#N](url)` and `[<KEY>]({{TRACKER_ISSUE_URL}}<KEY>)`.
7. **Reading view note:** the user reads in Obsidian Reading view, where `-` callouts collapse. Do not worry about how raw markdown looks in edit mode.
8. **Frontmatter** is filled from the run's data: `date`, `weekday`, `mit` (plain text, no links), `capacity`, `focus_window`. Add `tags: [daily]` if missing. Never delete user-added frontmatter keys.
