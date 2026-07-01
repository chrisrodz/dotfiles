# daily-note — consolidate, verify, classify, write

Shared engine for both phases. Read [config.md](config.md) and [layout.md](layout.md)
first. This file decides *which bucket* each item lands in (Doing / Done / Pending /
Info) and *how the note is written*; layout.md governs *how it renders*.

The pipeline is the same for CLOSE and OPEN — only the time windows, which buckets each
phase primarily fills, and the EOD-Compound handling differ. Those deltas are called
out inline as **[CLOSE]** / **[OPEN]**.

---

## Step 1 — Consolidate candidates

Build ONE unified candidate list from all gathering agents before classifying, so the
same real-world item is never written twice because Slack + GitHub + tracker + meeting
notes each phrased it differently.

1. **Extract raw findings** from every agent (and OPEN meeting prep). Capture: canonical
   key, source agent + detail (permalink / issue KEY / PR URL / doc ID / meeting title),
   raw text + agent-reported state, named entities + verb-object.
2. **Compute canonical key** per finding:
   - PR -> `<repo>#<N>`
   - tracker issue -> its KEY (matches `{{ISSUE_KEY_REGEX}}`)
   - free-text (Slack/meeting action item, commitment) -> `<named-entity>_<verb>_<object>` slug
   - A finding naming multiple keys is one candidate: PR key is primary, issue key becomes cross_ref.
3. **Merge by key** — fold every finding for a key into one candidate; carry all sources
   forward (used for attribution sub-bullets when 2+ sources merged).
4. **Topic-merge free-text candidates** — merge two free-text candidates that overlap on
   >=2 of: same named entity, shared Slack thread / meeting ID, verb-object similarity.

---

## Step 2 — Verify state & filter actionability

Do not trust agent-reported state. Re-fetch each candidate. Two gates:

### Gate 1 — State verification
- **PR** — `gh pr view <n> --repo {{GH_ORG}}/<repo> --json state,mergedAt,closedAt,reviewRequests`:
  - MERGED with `mergedAt` in the completion window (TARGET) -> route to **Done**.
  - MERGED/CLOSED before the window -> **drop entirely**.
  - OPEN -> continue to Gate 2.
- **tracker issue** — re-fetch via `get_issue`:
  - Done/Cancelled completed in window (TARGET; **[OPEN]** also YESTERDAY) -> route to **Done**.
  - Done/Cancelled before the window -> **drop entirely**.
  - else -> continue to Gate 2.
- **free-text** — no state; continue to Gate 2.

### Gate 2 — Direct-ownership filter
A candidate enters Doing or Pending only if at least one holds: user is PR author; user
is personally-requested reviewer (`requested_reviewers`, not team); user is tracker
assignee; user is explicitly named (one of `{{USER_ALIASES}}`) in the Slack/meeting
action item; user self-committed in their own message. Drop everything else **silently**
— no `⚠️ inferred` consolation, no Pending entry.
**Exception:** informational candidates (meeting recaps, decisions, Notion edits, FYIs
for Context/Info) bypass Gate 2.

Output: (1) verified actionable candidates, (2) informational candidates.

---

## Step 3 — Read the note & cross-reference

Read the note being written (`{{VAULT}}{{DAILY_DIR}}<date>.md`). If missing, create from
`{{VAULT}}{{TEMPLATE}}`. Migrate old `## 📓 Journal` + `###` notes to Variant A. Extract:
Right Now `🎯 MIT`; every `## 🔨 Doing` `[!abstract]-` callout; every `## ✅ Done` item;
every `## 📋 Pending` item; `## ℹ️ Context & meeting prep` callouts (so recaps append,
not overwrite); the whole-note key set (every PR/issue key anywhere, to enforce
one-item-one-bucket); and the USER-OWNED regions to preserve verbatim (Quick Log,
`> [!note] 📝 Notes`, and — for CLOSE — non-empty EOD Compound field values).

**Dedup:** a candidate is already-captured if the note already mentions its PR#, issue
KEY, the same action in other words, or the meeting's prep. Skip already-captured items.

---

## Step 4 — Classify each candidate into exactly one section

State (not topic or confidence) drives placement. **One item, one bucket.**

| Bucket | What goes here |
|---|---|
| **Done** (`## ✅ Done`, `[!success]-`) | Items Gate 1 routed to Done; Doing items completed this run. **[CLOSE] fills the bulk; [OPEN] only adds overnight auto-resolves.** |
| **Doing** (`## 🔨 Doing`, `[!abstract]-` per ticket) | Still in progress: open authored PRs, PRs personally requested for review, tracker In Progress / In Review. Carry-overs that didn't complete stay (re-badged to live state); new in-flight items added. |
| **Pending** (`## 📋 Pending`, `[!question]-` + `[!danger]-`) | Triage only: new-issue suggestions, Gate-2 follow-ups lacking a committed action, stale carry-overs. **Rewritten in full each run.** |
| **Context/Info** (`## ℹ️ Context & meeting prep`, `[!info]-`) | Informational: overnight scan, meeting prep (**[OPEN]**), meeting recaps (**[CLOSE]**), decisions, FYIs, Notion edits. No checkboxes. |

Per item type:
- **Carry-over Doing that completed this run** (PR merged / issue Done in window) -> Done
  `[!success]-` group as `- [x] **KEY** — title · merged/Done`; NOT also a Doing callout.
- **Carry-over Doing still open** -> Doing `[!abstract]-`, re-badged (`🚫`/`⏳`/`🔵`). No
  resolution signal at all -> inline `⚠️ status unclear — last activity: <signal or "none observed">`.
- **New work completed this run** -> Done group `- [x]`.
- **New work started, not done, with explicit commitment** -> Doing. Without commitment
  but passing Gate 2 -> Pending (`[!question]-`).
- **New-issue suggestions / Gate-2 follow-ups** -> Pending `[!question]-` (suggestions as
  copyable text; only for `{{TRACKER_TEAMS}}` and substantive work — never PR reviews,
  doc reviews, syncs, or meeting follow-ups).
- **Stale carry-overs** (unchecked in both prior day and day-before) -> Pending
  `[!danger]- 💤 Stale carry-overs` with `_(stale Nd)_`.
- **Meeting recaps** (**[CLOSE]**) -> append a `**✅ Recap:**` line INSIDE that meeting's
  existing `[!info]-` callout (don't duplicate `[OPEN]` prep). Recap = 3–4 terse bullets
  max: decisions + the user's action items + the single most important outcome.
- **tracker issue format:** Done -> `- [x] [<KEY>]({{TRACKER_ISSUE_URL}}<KEY>): title` in
  a Done group; In Progress/In Review -> Doing `[!abstract]-` titled `⏳ <KEY> · title — In Review`.

**Squad-channel context is reasoning input, not a section.** Use `SQUAD-CHANNEL CONTEXT`
to enrich/re-prioritize an existing item, promote a new action only if it independently
passes Gate 2, surface a still-firing incident into Watch, or add a genuinely useful
line to `📌 FYIs`. Never render it as its own section; never pad FYIs with chatter.

### Pending cap (max 5)
If Pending > 5, drop weakest until 5 remain. Ranking (strongest -> weakest): 1) items
already in Doing yesterday (user-owned, aging); 2) explicit user-named assignment, no
committed action; 3) user committed but next action fuzzy; 4) new-issue suggestions
(substantive only); 5) single-source follow-ups that barely passed Gate 2. Report the
dropped count in the wrap-up.

### Candidate rendering
2+ merged sources -> parent line + source-attribution sub-bullets:
```
- [x] [architect-api#26](url) — Refactor migration tooling — merged 3:14pm
    - github: PR merged on TARGET
    - slack #infra 3:42pm: Beverly approved final split
    - {{TRACKER}}: <KEY> → Done
```
Single-source -> flat line, no sub-bullets.

---

## Step 5 — Write

No approval gates. Write directly via the Edit tool, then print the wrap-up. Follow the
[layout.md](layout.md) write model: **re-render managed blocks wholesale; never surgically
patch a callout.** Fixed order: frontmatter → `# title` → Right Now → Watch (conditional)
→ Schedule → Quick Log → `---` → Doing → Done → Pending → Context → `---` → EOD Compound.
Insert any missing managed block in this order.

1. **Re-render Doing + Done together** from {existing note items} + {this run's
   candidates}. Resolved-this-run items render in Done; still-open items render in Doing
   badged to live state. Each KEY appears in exactly one bucket (the joint re-render
   guarantees it). Multi-source candidates carry source sub-lines.
2. **Refresh Right Now / Watch** — derive from live PR/ticket state (see layout.md
   "Deriving the top bands"). Keep `🎯 MIT` as the day's MIT. Drop Watch if no live risk.
   **[OPEN]** also builds/refreshes Schedule from the Calendar agent.
3. **Rewrite Pending in full** — `[!question]-` follow-ups + `[!danger]-` stale groups
   (omit an empty group). Apply the cap. If nothing to triage, render a single
   `> [!question] 📋 Pending` with body `> _Nothing to triage._`.
4. **Update Context & meeting prep** — **[OPEN]** writes one collapsed
   `[!info]- 🕐 HH:MM Title — attendees` callout per meeting (3–6 prep bullets) + an
   overnight-scan callout. **[CLOSE]** appends `**✅ Recap:**` into each meeting callout
   (create one only if `[OPEN]` was skipped). Notion edits + notable FYIs -> `📌 FYIs`.
5. **EOD Compound — [CLOSE] only.** Fill `Win` / `Learning` / `Tomorrow's MIT` with
   best-guess drafts each marked `⚠️ inferred`. Never overwrite a non-empty user value —
   append `_suggestion:_ …` below instead. Do not generate a `Tomorrow's Queue`
   (implicit in Doing/Pending). `Tomorrow's MIT` is what the next OPEN reads to seed the
   MIT. **[OPEN] never touches the EOD Compound callout.**
6. **Frontmatter** — set `date`, `weekday`, `mit` (plain), `capacity`, `focus_window`;
   add `tags: [daily]` if missing; never delete user-added keys. **[OPEN]** infers
   `capacity` from the calendar (>=4 meetings or >=3h blocks = `meeting-heavy (N)`; 0–1
   meetings = `light day`; else `full day`).

### Capacity & MIT (OPEN)
- **MIT** — from the prior day's EOD Compound `Tomorrow's MIT`; if empty, infer from
  carry-overs and mark `⚠️ inferred`. The MIT points to an item already in Doing.
- **Capacity** goes in frontmatter, not an Info bullet.
