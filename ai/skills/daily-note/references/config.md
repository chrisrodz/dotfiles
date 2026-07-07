# daily-note — configuration

Single source of environment-specific values for the `daily-note` skill. Read this
file FIRST on every run and substitute the `{{TOKENS}}` referenced throughout the
skill body and the other reference files.

Two kinds of values live here:

- **Personal** — real defaults, ready to use (vault path, timezone, your name).
- **Environment** — generic placeholders you must fill in for your company/tools
  (task tracker workspace, GitHub org, work email domain, squad channels). These are
  the values that were previously hardcoded; keeping them here is what makes the
  skill portable.

**Local override.** Real per-machine values live in `config.local.md` (gitignored) so
this committed file stays generic. If `config.local.md` exists, its token values
override the ones here. Copy the environment rows below into `config.local.md` and fill
them in.

If a token below still holds a `<PLACEHOLDER>` (and no override supplies it), the skill
must degrade gracefully:
skip the data source that needs it rather than guessing (e.g. no squad channels ->
skip squad catch-up; no work email domain -> fall back to "has a video link OR 2+
external attendees" for the work-meeting filter).

---

## Notes storage (personal)

| Token | Value |
|---|---|
| `{{VAULT}}` | `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/La Base/` |
| `{{DAILY_DIR}}` | `Daily Notes/` |
| `{{NOTE_FILENAME}}` | `YYYY-MM-DD.md` |
| `{{TEMPLATE}}` | `templates/daily note.md` |

Full daily-note path: `{{VAULT}}{{DAILY_DIR}}YYYY-MM-DD.md`. Use the exact iCloud
path; do not simplify the symlink.

The rendering layout is fixed — see [layout.md](layout.md) (do not put layout values
here).

## Time (personal)

| Token | Value |
|---|---|
| `{{TZ}}` | `America/Puerto_Rico` |
| `{{TZ_LABEL}}` | `AST` |

All clock math (Phase 0 date resolution, overnight windows, "now") uses `{{TZ}}`.

## Identity (personal)

| Token | Value |
|---|---|
| `{{USER_ALIASES}}` | `Christian A. Rodriguez Encarnacion / Christian Rodriguez / Christian / Chris` |
| `{{GITHUB_LOGIN}}` | resolve at runtime via `gh api user --jq '.login'` |
| `{{TRACKER_ME}}` | resolve at runtime via the tracker's `get_authenticated_user` |
| `{{SLACK_USER_ID}}` | resolve at runtime via `slack_search_users` on a name/email above |

`{{USER_ALIASES}}` drives every ownership gate: an action item "belongs" to the user
only when it names one of these aliases (or the resolved IDs above). Never guess IDs;
resolve them first each run.

---

## Task tracker (environment)

Default implementation is Linear via its MCP tools (`list_issues`, `get_issue`,
`get_authenticated_user`). If you use a different tracker, keep the same *behavior*
(fetch assigned/updated issues, verify state, link issues) with your tracker's tools.

| Token | Value |
|---|---|
| `{{TRACKER}}` | `Linear` |
| `{{TRACKER_ISSUE_URL}}` | `https://linear.app/<your-workspace>/issue/` |
| `{{ISSUE_KEY_REGEX}}` | `[A-Z]{2,}-\d+` |
| `{{ISSUE_KEY_EXAMPLES}}` | `<TEAM>-123`, e.g. `INFR-335`, `ARC-387` |
| `{{TRACKER_TEAMS}}` | `<teams/projects you are a member of>` — only suggest new issues for these |

Issue link format: `[<KEY>]({{TRACKER_ISSUE_URL}}<KEY>)`.

## GitHub (environment)

| Token | Value |
|---|---|
| `{{GH_ORG}}` | `<your-github-org>` |
| `{{PR_URL}}` | `https://github.com/{{GH_ORG}}/<repo>/pull/<number>` |

PR link format: `[<repo>#<N>]({{PR_URL}})`. `@me` in `gh` resolves to `{{GITHUB_LOGIN}}`.

## Meetings (environment)

| Token | Value |
|---|---|
| `{{WORK_EMAIL_DOMAIN}}` | `<yourcompany.com>` |

Work-meeting filter: has a video/conference link OR 2+ attendees on
`{{WORK_EMAIL_DOMAIN}}` OR organizer on `{{WORK_EMAIL_DOMAIN}}`. Exclude all-day
events, focus/block time, and personal events.

## Slack squad channels (environment)

`{{SQUAD_CHANNELS}}` — channels to catch up on for `SQUAD-CHANNEL CONTEXT` (reasoning
input, never its own section). The MCP cannot read starred channels directly, so keep
this list current as squads change. Resolve each name -> channel_id via
`slack_search_channels` with `channel_types: "public_channel,private_channel"` (most
are private), then read it.

```
<channel-a>, <channel-b>, <channel-c>, ...
# example: architect-core, ask-infra-engineering, dockmaster,
#          eng-infra-engineering, eng-infra-notifications, engineering,
#          local-dev-env, product-eng
```

Per-channel handling notes (adapt to your channels): treat any automated
notifications/alerts channel as an alert feed (extract only genuine incidents, not
routine deploy notices); treat high-traffic/social channels as low-signal (keep only
substantive items).
