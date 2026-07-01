---
name: daily-note
description: Transition an Obsidian daily note from one day to the next — close out the outgoing day (fill Done, meeting recaps, EOD compound) and open the incoming day (carry-over, meeting prep, prioritized plan) by gathering Slack, GitHub, task-tracker, calendar, and meeting-notes activity. Use when the user runs a start-of-day or end-of-day routine, asks to plan the day, wrap up the day, roll their notes forward, or invokes /daily-note, /sod, or /eod.
---

# daily-note

Runs a start-of-day / end-of-day routine against the user's Obsidian daily note. It has
two phases that combine into one "transition":

- **CLOSE** (end-of-day): finalize the outgoing day — fill `## ✅ Done`, append meeting
  `**✅ Recap:**` lines, refresh statuses, fill the `🌙 EOD Compound`.
- **OPEN** (start-of-day): open the incoming day — carry over unfinished work, prep each
  meeting, and compose the prioritized plan (MIT, Right Now, Doing, Pending, Schedule).

Because the user runs this either late at night or first thing in the morning, the
default run does both: it CLOSEs the outgoing day and OPENs the incoming day in one pass.
The outgoing day's `Tomorrow's MIT` seeds the incoming day's MIT.

## Read first (every run)

1. [references/config.md](references/config.md) — environment-specific values
   (`{{TOKENS}}`). Substitute these everywhere. If a token is an unfilled
   `<PLACEHOLDER>`, skip the source that needs it rather than guessing.
2. [references/layout.md](references/layout.md) — the "Variant A" callout layout + write
   model. Render exactly this.

The two heavy references are loaded per phase:
- [references/data-gathering.md](references/data-gathering.md) — the parallel sub-agent prompts.
- [references/classify-and-write.md](references/classify-and-write.md) — consolidate, verify state, ownership gates, classify, write.

## Phase A — resolve mode + dates

Parse `$ARGUMENTS`, then resolve all dates with the `date` CLI in `{{TZ}}` (never guess
the weekday). Accepts `YYYY-MM-DD`, `today`, `yesterday`, `tomorrow`.

| Argument | Mode | OUTGOING (closed) | INCOMING (opened) |
|---|---|---|---|
| _(empty)_, and local hour ≥ 17 | transition | today | tomorrow |
| _(empty)_, and local hour < 17 | transition | yesterday | today |
| `<date>` or `transition <date>` | transition | most recent existing note before `<date>`, else `<date>`−1 | `<date>` |
| `close [date]` | close only | `date` (default today) | — |
| `open [date]` | open only | — | `date` (default today) |

```bash
# resolve in the user's timezone
TZ='{{TZ}}' date "+%Y-%m-%d %A %H"          # today + weekday + hour (for the ≥17 rule)
TZ='{{TZ}}' date -v-1d "+%Y-%m-%d %A"        # yesterday
TZ='{{TZ}}' date -v+1d "+%Y-%m-%d %A"        # tomorrow
# validate an explicit date:
TZ='{{TZ}}' date -j -f "%Y-%m-%d" "YYYY-MM-DD" "+%Y-%m-%d %A" 2>/dev/null
```

Also compute, for the OPEN phase, `INCOMING−1` (prior note, for carry-over) and
`INCOMING−2` (for stale-carry-over detection).

**Skip CLOSE** if the OUTGOING daily note does not exist (nothing to close) — just OPEN.
**Run order for a transition:** CLOSE first, then OPEN (so the fresh `Tomorrow's MIT`
seeds the incoming MIT).

## Phase B — CLOSE (skip if mode is `open`)

Target date = OUTGOING. Window = the full OUTGOING day.

1. **Gather** — launch these agents in one message (see data-gathering.md, WINDOW = the
   OUTGOING day): Slack, GitHub PRs, `{{TRACKER}}` issues, Calendar, Meeting notes
   (MN_WINDOW = OUTGOING), Notion.
2. **Consolidate → verify → classify → write** — follow classify-and-write.md applying
   the **[CLOSE]** deltas: fill the bulk of `## ✅ Done`; append `**✅ Recap:**` into each
   meeting's `[!info]-` callout; rewrite `## 📋 Pending`; refresh Right Now to end-of-day
   reality; fill the `🌙 EOD Compound` (`Win` / `Learning` / `Tomorrow's MIT`, inferred
   fields marked `⚠️ inferred`, never overwriting non-empty user values).
3. **Wrap-up** (chat):
```
🌙 CLOSE wrote to {{DAILY_DIR}}OUTGOING.md
  ✅ Done: M (K resolved from Doing, N landed without prior Doing)
  🔨 Doing: N still open (U badged "status unclear")
  📋 Pending: P for triage — D dropped this run
  ℹ️ Context: R recaps, F FYIs
  🌙 Compound: Win / Learning / Tomorrow's MIT drafted (⚠️ inferred marked)
```

## Phase C — OPEN (skip if mode is `close`)

Target date = INCOMING. Window = overnight (since ~17:00 `{{TZ}}` the day before INCOMING).

1. **Bootstrap** — read INCOMING note (create from `{{TEMPLATE}}` if missing; migrate old
   `## 📓 Journal` notes to Variant A). Read `INCOMING−1` and `INCOMING−2`. From
   `INCOMING−1`'s `🌙 EOD Compound` take `Tomorrow's MIT` (→ today's MIT). Carry over:
   `INCOMING−1` Doing (incomplete → Doing), `INCOMING−1` Pending (unchecked → Pending);
   never carry Done or Context. Items unchecked in BOTH `INCOMING−1` and `INCOMING−2`
   Doing/Pending are stale → Pending with `_(stale Nd)_`.
2. **Gather** — launch in one message (data-gathering.md, WINDOW = overnight): Slack,
   GitHub PRs, `{{TRACKER}}` issues, Calendar (INCOMING), Meeting notes
   (MN_WINDOW = INCOMING−1, action items only).
3. **Meeting prep** — one agent per work meeting from the Calendar results, in one
   message (data-gathering.md "Meeting prep"). Skip if no work meetings.
4. **Consolidate → verify → classify → write** — follow classify-and-write.md applying
   the **[OPEN]** deltas: build `## 🔨 Doing`; add only overnight auto-resolves to Done;
   write per-meeting prep + overnight-scan in Context; derive Right Now / Watch /
   Schedule bands; infer `capacity`; set MIT. **Never touch the `🌙 EOD Compound`.**
5. **Wrap-up** (chat):
```
☀️ OPEN wrote to {{DAILY_DIR}}INCOMING.md
  🎯 MIT: <today's #1>
  ▶ Right Now: <awaiting-me> awaiting me, <blocked> to unblock, next: <next meeting>
  🔨 Doing: N (M carried, K new)   ✅ Done: K auto-resolved overnight
  📋 Pending: P (S stale, I inferred) — D dropped this run
  ℹ️ Context: N meetings prepped · capacity: <…> (frontmatter)
```

## Rules

- **No approval gates.** Write directly via the Edit tool. Pending is the triage surface.
- **Config-driven, no hardcoded company values.** Everything environment-specific lives
  in config.md. If a `{{TOKEN}}` is an unfilled `<PLACEHOLDER>`, skip that source
  silently — never invent an org, tracker URL, email domain, or channel list.
- **Render Variant A callouts (layout.md).** Callouts are agent-owned: re-render managed
  blocks wholesale from live data each run; never surgically patch a callout interior.
  Re-running any phase is idempotent.
- **One item, one bucket.** Every PR / tracker issue / free-text action appears exactly
  once in Doing | Done | Pending, matching its verified state. Right Now references keys
  without re-stating them.
- **Consolidate before classifying; verify state; never trust agent-reported state.**
  Merged/closed PRs and Done/Cancelled issues older than the window are dropped.
- **Direct-ownership filter.** Actionable items enter Doing/Pending only with a real
  ownership signal (author, personally-requested reviewer, assignee, named in
  `{{USER_ALIASES}}`, or self-committed). Collective/third-party items are dropped
  silently — no `⚠️ inferred` consolation. Informational items bypass the gate.
- **Pending capped at 5.** Drop weakest; report the dropped count.
- **Visible uncertainty over silent guessing** for items that passed the gate
  (`⚠️ inferred`, `⚠️ status unclear — …`, `_(stale Nd)_`, `_proposed: <bucket>_`).
- **Preserve user-owned regions byte-for-byte:** Quick Log contents, any
  `> [!note] 📝 Notes` callout, and non-empty EOD Compound values. OPEN never writes the
  EOD Compound; CLOSE owns it.
- **The task tracker is read-only.** New-issue suggestions are copyable text in Pending,
  only for `{{TRACKER_TEAMS}}` and substantive work (never PR reviews, syncs, doc
  reviews, or meeting follow-ups). Never create issues or comments.
- **Links mandatory** for every PR (`[repo#N]({{PR_URL}})`) and tracker issue
  (`[<KEY>]({{TRACKER_ISSUE_URL}}<KEY>)`).
- **Meeting recaps** (CLOSE) go inside the meeting's `[!info]-` callout as `**✅ Recap:**`
  (3–4 terse bullets); meeting prep (OPEN) is one collapsed `[!info]-` per meeting.
- **Graceful degradation.** If a data source returns nothing or errors (common for
  meeting notes — user didn't host), skip it silently; no empty sections.
- **Use the exact iCloud vault path** from config; do not simplify the symlink.
- **Always resolve dates via Phase A in `{{TZ}}`.** Never guess the weekday.
