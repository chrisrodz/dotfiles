# daily-note — data gathering (parallel sub-agents)

All sub-agent prompts for both phases. Read [config.md](config.md) first and
substitute `{{TOKENS}}`. Launch the agents for a phase **in a single message** so they
run concurrently. Use `subagent_type: "general-purpose"` (or `generalPurpose`) for all.

Two time windows:
- **OPEN phase** — overnight window: since ~17:00 `{{TZ}}` on the day *before* INCOMING,
  up to now. Reads carry-over from prior notes; does meeting prep.
- **CLOSE phase** — the full OUTGOING day (00:00–23:59 `{{TZ}}`).

In every prompt below, replace `TARGET` / `WINDOW` / `DAYNAME` with the resolved values
from the run, and `{{TOKENS}}` with config values. If a token is an unfilled
`<PLACEHOLDER>`, skip that source silently.

---

## Shared principle for all human-signal agents (Slack, meeting notes)

ACCURACY OVER COVERAGE. Every ownership claim and every action item MUST be grounded in
a specific message/section actually read in full. Do NOT infer content or authorship
from a search snippet, and NEVER reconstruct a thread you could not open. If you cannot
read something, say so explicitly (`⚠️ unread`). Do not pad to look thorough.

**Direct-ownership gate.** An action item "belongs to the user" only when it names one
of `{{USER_ALIASES}}` (or the resolved `{{SLACK_USER_ID}}` / `{{GITHUB_LOGIN}}` /
`{{TRACKER_ME}}`), the user is the PR author or personally-requested reviewer, the user
is the tracker assignee, or the user self-committed in their own message. Collective
("team should…") and third-party ("follow up with <user> about X" = someone else's
todo) items are dropped. Informational candidates (decisions, FYIs, meeting recaps)
bypass this gate.

---

## Agent: Slack

```
Gather the user's Slack activity for WINDOW (DAYNAME TARGET).
Apply ACCURACY OVER COVERAGE and the direct-ownership gate.

STEP 1 — Resolve identity FIRST (do not guess).
- Call slack_search_users / slack_read_user_profile with a name/email from
  {{USER_ALIASES}} to get the exact user ID. Use it for from:/mention filters.
- Do NOT use "from:me" / "@me" — unreliable in this MCP. Use the resolved ID.

STEP 2 — Find candidate messages in WINDOW.
- slack_search_public_and_private with from:<ID> and the WINDOW date filter
  (on:TARGET, or after:/before: for the overnight window). Also search @<ID> mentions,
  and DMs received in the window.

STEP 3 — Read EVERY candidate thread IN FULL (mandatory).
- Get the thread id from the result payload — do NOT guess thread_ts. Root = result's
  thread_ts if present else its own ts; the permalink also encodes both.
- slack_read_thread(channel_id, thread_ts) for every thread with the user's message,
  an @mention, or an incoming DM. Top-level pings are often resolved in-thread.
- On error/empty, retry once with the alternate id (root vs leaf). If still failing,
  mark items ⚠️ unread — could not open thread, and assert no ownership/urgency/resolution.

STEP 4 — Determine ownership/resolution from messages READ, not snippets.
- Note whether the user already replied (treat as addressed). For each action item cite
  the verbatim line proving ownership; classify the signal (mentioned by name /
  self-committed / named assignee / none).

STEP 5 — Extract per relevant thread: channel + permalink; 1–2 line summary; action
  items (each with the ownership line); decisions; named entities + verb-object;
  urgency (blocking someone / time-sensitive / normal); ownership signal + confidence
  (read-verified | ⚠️ unread).

STEP 6 — Squad/team channel catch-up (CONTEXT for reasoning, NOT action items).
- Read WINDOW for each channel in {{SQUAD_CHANNELS}} (resolve name -> channel_id via
  slack_search_channels with channel_types "public_channel,private_channel"; most are
  private). Use slack_read_channel(channel_id, oldest=<epoch for WINDOW start in {{TZ}}>).
  Open a thread only when a top-level message is clearly relevant.
- FILTER HARD to work-stream relevance: decisions/announcements; blockers/unblocks on
  the user's active tickets/PRs; items where someone waits on the user; context that
  changes something the user is already working on. Apply per-channel handling from
  config (alert feeds -> incidents only; social/high-traffic -> substantive only).
- Do NOT apply the ownership gate here (awareness, not action items) but DO apply the
  no-reconstruction rule. Skip routine chatter — silence is a valid result.
- Return under a separate SQUAD-CHANNEL CONTEXT heading: channel, permalink, 1-line
  gist, work stream/ticket it touches.

Return three streams: (1) action items (ownership-gated), (2) Info candidates
(decisions/FYIs), (3) SQUAD-CHANNEL CONTEXT. End with an explicit list of anything you
could NOT read. In the CLOSE phase, focus on what happened today; in OPEN, focus on
what needs action TODAY and skip items the user already addressed.
```

## Agent: GitHub PRs

```
Gather the user's GitHub PR activity for WINDOW using the gh CLI.

1. Authored PRs:
   - OPEN phase: gh pr list --author=@me --state=open --json number,title,repository,reviews,statusCheckRollup,updatedAt
     For each: new reviews since WINDOW start? CI passing/failing/pending? merge-ready?
   - CLOSE phase: gh search prs --author=@me --updated=>=TARGET --json repository,number,title,state,mergedAt,closedAt,updatedAt
2. Review requests (PERSONAL only, not team):
   a. login: gh api user --jq '.login'   (= {{GITHUB_LOGIN}})
   b. candidates: gh search prs --review-requested=@me --state=open --json repository,number,title,author,updatedAt
   c. verify per candidate: gh pr view <n> --repo {{GH_ORG}}/<repo> --json reviewRequests
      Keep only if reviewRequests contains the user's login (requested_reviewers).
      Discard team-only requests (requested_teams).
3. Per PR return: link ({{PR_URL}}); role (author/reviewer); status (needs attention /
   merge-ready / waiting / CI failing); what changed in WINDOW; state (OPEN/MERGED/
   CLOSED) with mergedAt/closedAt.

STATE FILTER:
- MERGED/CLOSED with timestamp BEFORE the window -> drop (old news).
- MERGED on TARGET -> label "state: MERGED today" (routes to Done).
- OPEN -> return normally.
Only include PRs the user authored OR personally reviewed in WINDOW.
```

## Agent: {{TRACKER}} issues

```
Gather the user's {{TRACKER}} activity for WINDOW.

1. get_authenticated_user -> the user's identity ({{TRACKER_ME}}).
2. list_issues for issues assigned to the user updated in WINDOW, plus issues the user
   commented on in WINDOW. (OPEN also: newly assigned since window start.)
3. Per issue: KEY (matches {{ISSUE_KEY_REGEX}}); title; current status; what changed in
   WINDOW (status transitions, comments, linked PRs, blockers, priority); completion
   timestamp if Done/Cancelled.

STATE FILTER:
- Done/Cancelled completed in WINDOW (TARGET, or YESTERDAY for OPEN) -> label
  "state: Done today" (routes to Done).
- Done/Cancelled completed BEFORE the window -> drop (old news).
- In Progress / In Review / Todo -> return normally.
Only issues where the user is assignee or commented in WINDOW. This tracker is
READ-ONLY: never create issues or comments.
```

## Agent: Calendar (TARGET day meetings)

```
Get TARGET (DAYNAME) meetings from Google Calendar.
1. gcal_list_events for TARGET.
2. Per event: title; start/end; organizer (name+email); attendees (names+emails);
   description/notes; linked docs (Google Docs / Notion links); video/Zoom link (+ID).
3. Work-meeting filter: has a video/conference link OR 2+ attendees on
   {{WORK_EMAIL_DOMAIN}} OR organizer on {{WORK_EMAIL_DOMAIN}}. Exclude all-day events,
   focus/block time, personal events. (If {{WORK_EMAIL_DOMAIN}} is unset, use "video
   link OR 2+ attendees".)
Return work meetings sorted by start with full attendees + linked docs.
```

## Agent: Meeting notes (Zoom AI Companion — default provider)

Only returns data for meetings the user HOSTED; this ENRICHES the calendar list, it is
not the primary meeting source. Degrade gracefully on auth/permission errors — never
block the run on meeting-notes failures.

```
Retrieve meeting-notes data for MN_WINDOW.
  - OPEN phase: MN_WINDOW = YESTERDAY. Return only ACTION ITEMS assigned to the user.
  - CLOSE phase: MN_WINDOW = TARGET. Return outcomes, decisions, action items, pending
    confirmations, attendees — for meeting recaps.

PRIMARY: Zoom Docs "My Notes"
1. list_docs(parent_id="root") -> find the "My notes" folder (file_type "folder").
   If missing or list_docs fails (scope error), skip to FALLBACK.
2. list_docs(parent_id=<folder_id>) -> filter to notes with created_time on MN_WINDOW.
3. For each match (max 5 — get_doc_content is rate-limited) call get_doc_content(file_id).
   Extract sections: Key Outcomes, Decisions Made, Action Items ("**Name**: text"),
   Engineering/Data Status, Pending Confirmation. Match docs to meetings by name/time.

FALLBACK/SUPPLEMENT: meeting summary API
4. list_meetings(type="previous_meetings") -> filter start_time on MN_WINDOW (one-offs).
5. list_upcoming_meetings -> recurring IDs; for each get_past_meeting(meeting_id) (numeric
   ID). Skip "No permission"/"Not found" silently. get_past_meeting returns the MOST
   RECENT occurrence — verify start_time is on MN_WINDOW.
6. For confirmed meetings with has_meeting_summary: get_meeting_summary(meeting_id) ->
   summary_overview, summary_details labels, next_steps (assignees). Optionally
   get_past_meeting_participants for attendees.

Prefer Docs (richer) and supplement with API participants/next_steps. Per meeting
return: title+time; attendees; key outcomes; decisions; action items with assignees
(FLAG the user's); discussion topics; pending confirmations; named entities +
verb-object per action item.

OWNERSHIP GATE for action items: keep only those assigned to {{USER_ALIASES}}. Drop
"everyone/the team/<someone else>" and "follow up with <user>" (someone else's todo).
Decisions/outcomes are Info candidates regardless of ownership.
Do NOT use list_meetings_with_transcripts / list_recordings — they miss AI Companion data.
```

## Agent: Notion (CLOSE phase only — user-edited pages)

```
Find Notion pages the user PERSONALLY edited on TARGET.
1. notion-search for recently modified pages.
2. Filter to last_edited_time on TARGET.
3. Keep ONLY pages last-edited by the user (skip team edits).
4. Per page: title; last edited time; brief summary of the change if discernible.
Return an empty list if none — do not surface team activity.
```

---

## Meeting prep (OPEN phase only — one agent per work meeting)

After the OPEN gathering agents return, launch one agent per work meeting from the
Calendar agent's results, all in a single message. Skip entirely if no work meetings.

```
Prepare a brief meeting prep for: [MEETING_TITLE]
Time: [START]-[END]  Organizer: [ORGANIZER]  Attendees: [ATTENDEES]
Description: [DESC]  Linked docs: [DOCS_OR_NONE]

Research and compile a prep brief:
1. Slack (48h): slack_search_public_and_private for threads involving the attendees or
   topic keywords.
2. {{TRACKER}}: list_issues related to the topic or shared with attendees.
3. Linked docs: note titles + recent updates (Notion via notion-search/notion-fetch).
4. Recurring meeting: note context from the user's recent daily notes on prior occurrences.
5. Previous occurrence via meeting notes:
   a. Zoom Docs: list_docs "My notes" -> find a doc whose file_name matches the meeting
      title, most recent BEFORE today -> get_doc_content -> extract Action Items (open
      follow-ups) and Decisions Made.
   b. Else, if it has a Zoom link: get_past_meeting(id) (start_time BEFORE today) ->
      get_meeting_summary if has_meeting_summary -> next_steps + summary_details.
   c. Skip on "No permission"/error (user didn't host).
   d. Include open action items from the previous occurrence as follow-up points.

Output a flat list of 3–6 bullets, each a concrete prep point (raise / follow up /
share / ask), with PR numbers, {{TRACKER}} keys, or channel names inline. If research
yields nothing useful, return: "No specific prep needed — standard sync."
```
