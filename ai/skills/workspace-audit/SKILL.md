---
name: workspace-audit
description: Audit agent workspace to identify knowledge gaps about the user, their business, projects, and context. Use monthly or when onboarding a new workspace. Generates a fillable gaps document for the user.
---

# Workspace Audit Skill

Comprehensive audit of what the agent knows (and doesn't know) about the user. Run monthly or after major life/work changes.

## When to Use

- Monthly knowledge maintenance
- After onboarding a new workspace
- When the user asks "what do you know about me?"
- Before major planning sessions (quarterly reviews, goal setting)

## Workflow

### 1. Read All Context Files

```bash
# Core identity files
cat ~/clawd/USER.md
cat ~/clawd/MEMORY.md
cat ~/clawd/BUSINESS-PROFILE.md 2>/dev/null
cat ~/clawd/IDENTITY.md 2>/dev/null

# Memory files (recent + key)
find ~/clawd/memory -type f -name "*.md" | head -50 | xargs cat

# Skills (scan descriptions)
head -20 ~/clawd/skills/*/SKILL.md
```

### 2. Categorize Known Information

Build a mental model of:

**Personal**
- Name, location, timezone
- Family members + relationships
- Health/fitness patterns
- Communication preferences

**Professional**
- Current employer + role
- Work patterns (meeting days, focus time)
- Team members mentioned
- Career goals

**Business/Side Projects**
- Active projects + stages
- Revenue status
- Collaborators
- Strategic positioning

**Financial**
- Income sources
- Savings goals
- Investment strategy
- Current constraints

### 3. Identify Gaps

For each category, note:
- 🔴 **Critical gaps** — blocks daily helpfulness
- 🟡 **Medium gaps** — would improve assistance
- 🟢 **Nice to have** — optional enrichment

Common critical gaps:
- Spouse/partner profile (if agent switches personas)
- Work context (projects, team, stack)
- Active projects with no documentation
- Key contacts without context

### 4. Generate Gaps Document

Create a fillable template at the user's preferred location (Obsidian vault or workspace).

**Template structure:**

```markdown
# 🔍 [Agent Name] Knowledge Gaps

*Created: YYYY-MM-DD*

## 🔴 Critical

### [Gap Category]
- **Field:** 
- **Field:** 

## 🟡 Medium Priority

### [Gap Category]
- **Field:** 

## 🟢 Nice to Have

### [Gap Category]
- **Field:** 

## 📝 Instructions
1. Fill what you can, when you can
2. Voice notes work — agent will extract
3. Tell agent when a section is done to process
```

### 5. Deliver Summary

Send the user:
1. What you know (brief summary by category)
2. What's missing (prioritized gaps)
3. Location of the gaps document
4. Offer to set up monthly cron

## Output Locations

- **Gaps doc:** User's Obsidian vault or `~/clawd/memory/GAPS-TO-FILL.md`
- **Processed data:** Distribute to appropriate files (USER.md, MEMORY.md, contacts.md, etc.)

## Monthly Cron Setup

If user wants recurring audits:

```yaml
schedule:
  kind: cron
  expr: "0 12 1 * *"  # 1st of month at noon
  tz: America/Puerto_Rico
payload:
  kind: agentTurn
  message: "Run workspace-audit skill. Read all memory files, identify new gaps, and send me a summary of what you know vs what's missing."
```

## Processing User Input

When user fills gaps doc or sends voice notes:

1. Extract structured data
2. Update appropriate files:
   - Personal info → USER.md
   - Business context → BUSINESS-PROFILE.md
   - Contacts → memory/contacts.md (create if needed)
   - Project details → memory/projects/ or project-specific notes
3. Mark sections as processed in gaps doc
4. Confirm what was updated

## Quality Checks

- [ ] All core files read
- [ ] Gaps prioritized (not just listed)
- [ ] Document created in accessible location
- [ ] Summary sent to user
- [ ] Cron offered if not set up
