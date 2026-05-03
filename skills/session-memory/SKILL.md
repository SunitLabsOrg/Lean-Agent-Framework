---
name: session-memory
description: Persists agent state, decisions, and execution plans across sessions. Enables resuming work after context switches or tool changes.
category: meta
version: 1.0.0
---

# @session-memory — Session Memory & State Persistence

**Philosophy:** When context is lost (tool switch, day break, network drop), decisions and progress shouldn't disappear.

## When to invoke

- Multi-session work (feature takes 2+ days)
- Tool switch (PM starts in Cursor, Dev continues in Claude Code)
- Resuming work after long break
- Need to preserve decisions for future reference
- Want audit trail of what was decided and why

## Responsibilities

- Maintain a chronological log of work (`memory.md`)
- Record decisions made, why, and by whom
- Note blockers, open questions, assumptions
- Summarize current state: what's done, what's in progress, what's next
- Make log findable and easy to read
- Update at end of session (or multiple times during long sessions)

## Memory Format

Create: `memory.md` (root level or `.project/memory.md`)

Template:

```markdown
# Session Memory: [Feature Name]

**Feature:** [Name and brief description]
**Started:** YYYY-MM-DD
**Last updated:** YYYY-MM-DD HH:MM
**Status:** In Progress / Blocked / Complete

---

## Session Log (Chronological)

### Session 1: 2026-05-03 09:00 - 11:30 (PM Sunit)

**Goal:** Scope user comments feature

**Work done:**
- Interviewed 3 users about pain point
- Created spec: docs/specs/2026-05-03-user-comments.md
- Added acceptance criteria (testable, clear)
- Decided: comments on posts only, not nested replies (Phase 2)
- Decided: moderation done manually in v1 (Phase 2: AI moderation)

**Decisions made:**
- IN SCOPE: Comments on posts, edit/delete own comments, like a comment
- OUT OF SCOPE: Nested replies, spam detection, notification to post author
- ASSUMPTION: Authentication already exists (verified: ✅)

**Blockers:** None

**Open questions:**
- Do we need to notify the post author when someone comments? (Ask PM tomorrow)

**Next session:** @scope-audit to check for risks

**Notes:** Spec is tight and user-focused. Team agrees this is ship-worthy in 2 weeks.

---

### Session 2: 2026-05-03 14:00 - 15:30 (Dev Lead)

**Goal:** Audit spec for risks, design architecture

**Work done:**
- Reviewed spec: looks good
- Ran @scope-audit: verdict PASS (no major risks)
- Created tech design: docs/architecture/user-comments-design.md
- Decided: PostgreSQL (existing), no new infrastructure
- Decided: API-first (backend first, then web UI)

**Decisions made:**
- Architecture: Monolith (existing), comments table, foreign keys to posts and users
- API: POST /posts/:id/comments, GET /posts/:id/comments, DELETE /comments/:id
- Data: comments table (id, post_id, user_id, text, created_at, updated_at)

**Blockers:** None

**Assumptions:**
- PostgreSQL migrations work on this project (verified: ✅)
- User authorization already built (verified: ✅)
- API rate limiting not needed for v1 (PM confirms: ✅)

**Risks identified:**
- Concurrent comment creation could cause duplicate IDs → mitigation: use UUID primary key
- Comment author deletion should soft-delete → decision: soft-delete + mark as deleted

**Next session:** @developer to implement

**Notes:** Design is straightforward. No unexpected complexity. Good scope.

---

### Session 3: 2026-05-04 10:00 - 16:00 (Dev Lead)

**Goal:** Implement comment feature

**Work done:**
- Created database migration: comments table with UUID PK
- Implemented API endpoints:
  - POST /posts/:id/comments (create)
  - GET /posts/:id/comments (list)
  - DELETE /comments/:id (soft delete)
- Wrote unit tests: 12 tests, all passing
- Ran @self-check: caught 2 missing edge case tests
- Added edge case tests: fixed both
- Ran @code-reviewer: PASS (security, conventions OK)

**Decisions made:**
- Soft delete: comment marked as deleted, not removed from DB
- Timestamps: UTC, stored in DB, returned in API
- Pagination: not implemented (will add in Phase 2 if needed)

**Blockers:** None

**Assumptions:**
- JWT token from auth middleware exists (verified: ✅)
- User ID available in request context (verified: ✅)

**Test results:**
- Unit tests: 14 passing, 0 failing
- Coverage: 88% (acceptable)
- Manual test: created comment, edited, deleted — all working

**Next steps:** Ready to merge

**Notes:** Feature is complete and tested. Quality is high. Low risk to ship.

---

## Current State Summary

**What's DONE:**
- ✅ Spec written and approved
- ✅ Scope audit passed (no risks)
- ✅ Architecture designed
- ✅ Implementation complete
- ✅ Tests passing (88% coverage)
- ✅ @self-check passed (edge cases covered)
- ✅ @code-reviewer passed (security, conventions OK)

**What's IN PROGRESS:**
- [ ] (None — ready for final review)

**What's NEXT:**
- Merge to main
- Deploy to staging
- Brief QA / manual testing
- Deploy to production

**Blockers:**
- (None)

**Open questions:**
- Should we notify post author of new comments? (PM decision, Phase 2)
- Do we need to track comment edit history? (PM decision, Phase 2)

---

## Key Decisions (Reference)

| Decision | Chosen | Why | Tradeoff | When it breaks |
|----------|--------|-----|----------|---|
| Monolith | Yes | Team size, latency | Hard to scale comment service independently | If 10x users need it |
| PostgreSQL | Yes | Relational data, ACID | Not flexible schema | If schema changes frequently |
| Soft delete | Yes | Preserve audit trail, referential integrity | Uses more space | If we need to truly delete |
| UUID PK | Yes | Prevents concurrent creation bugs | Larger indexes | If ID size becomes bottleneck |
| No pagination v1 | Yes | Simple, most posts < 100 comments | Poor UX if 1000+ comments | When load testing shows issue |
| Manual moderation | Yes | Simple, no ML infrastructure | Doesn't scale | If spam becomes problem |

---

## Assumptions Made

- [ ] Authentication layer exists and works (verified: ✅)
- [ ] User ID available in request context (verified: ✅)
- [ ] PostgreSQL migrations auto-run on deploy (verified: ✅)
- [ ] API rate limiting not needed in v1 (PM: ✅)
- [ ] Users won't create 1000+ comments per post (reasonable: ✅)

---

## Lessons Learned

(To be filled in at project end)

- What went well: [notes]
- What was hard: [notes]
- What would we do differently: [notes]
- What surprised us: [notes]

---

## Quick Resume

If you're picking this up mid-project:

1. **Read the summary above** (30 seconds)
2. **Check "What's DONE" and "What's NEXT"** (30 seconds)
3. **Review "Key Decisions"** to understand architecture (2 min)
4. **Read the latest session** for context (5 min)
5. **Ready to continue** ✅

---

**Updated by:** [Your Name]  
**Last activity:** 2026-05-04 16:00  
**Next session planned:** [date and time if planned]
```

## Memory Rules

### Timing
- Update at end of each work session (or every 2-3 hours during long sessions)
- Record decisions immediately (don't wait until end of day)
- Include timestamps for all entries

### Content
- **What's done:** Be specific (commit hash, file names)
- **What's in progress:** Current blockers, next steps
- **What's next:** Clear next action (which skill to invoke, or deploy)
- **Decisions:** Why was it chosen, what was the tradeoff
- **Assumptions:** What we're betting on
- **Blockers:** What's stuck, why, who's working on it
- **Open questions:** What we don't know, who needs to answer

### Style
- Chronological (latest at bottom, or use header anchors)
- Scannable (use bullet points, tables, bold for emphasis)
- Specific (not vague: "working on API" is bad; "implementing GET /posts/:id/comments" is good)

### Access
- Store in Git (version control, searchable)
- Make it readable (markdown, not JSON or code)
- Link to artifacts (spec.md, tech-spec.md, commits)

## Usage Patterns

### Resume After Day Break

```
@session-memory: "What did we do yesterday? What should I do next?"

Read memory.md → understand state → continue from next action
```

### Hand Off Between Tools

```
Dev in Cursor: "Saving work to memory.md"
Dev in Claude Code: "Reading memory.md, resuming..."
```

### Multi-Person Handoff

```
PM in Cursor: "Scoping feature, recording decisions to memory.md"
Dev in Claude Code: "Reading memory.md, continuing architecture phase"
```

## Handoff

**Next skill:** Any skill (memory is always available as reference)

**What to do with memory.md:**
- Commit to Git
- Reference it when resuming work
- Update it at end of each session
- Use it for onboarding new team members

## Artifact

**Output:** `memory.md` (root level or `.project/memory.md`)

This is your audit trail and resume mechanism. Keep it current.

## Anti-patterns (do not do)

- Don't record vague notes ("worked on stuff")
- Don't delete old sessions (keep for audit trail)
- Don't forget to update before switching tools or ending day
- Don't record decisions without context (why was it chosen?)
- Don't treat memory.md as a todo list (use `.project/stories.md` for todos)
