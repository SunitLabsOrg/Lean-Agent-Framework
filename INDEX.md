# Lean Agent Framework — Skill Index

*Authoritative reference for all 8 skills. For quick overview, see [README.md](README.md).*

---

## All Skills at a Glance

| Skill | Role | What it does | Produces | When to use |
|---|---|---|---|---|
| **@spec-writer** | Product | Translate vague idea into scoped spec with acceptance criteria | `spec.md` | New feature or PM needs to clarify scope |
| **@scope-audit** | Product | Audit spec for risks, unsupported assumptions, adoption failures | `scope-audit-report.md` (PASS/REVISE/ABANDON) | Before architecture begins (gating skill) |
| **@architect** | Engineering | Design system, data flows, service boundaries, tradeoffs | `tech-spec.md` | Spec approved, ready to design |
| **@developer** | Engineering | Implement code + tests following architecture | Code diff + test report | Design approved, ready to build |
| **@self-check** | Engineering | Pre-handoff quality check, catch obvious issues | Annotated diff (inline) | Code written, before handoff to @code-reviewer |
| **@code-reviewer** | Engineering | Security, conventions, boundaries check | `review-report.md` or explicit PASS | Before merging to main |
| **@quality-check** | Engineering | Edge case testing, hunt for failure modes | Test report | High-risk changes (auth, payments, migrations) |
| **@session-memory** | Meta | Persist state, decisions, execution plans across sessions | `memory.md` (chronological log) | Multi-session work, tool switches, resume |

---

## Skill Workflows

### Standard Feature Workflow

```
@spec-writer
  (PM: "Scope this feature")
  → spec.md (with problem, acceptance criteria, in/out of scope)
  
  ↓ [GATE: PM adds approval marker]
  
@scope-audit
  (PM: "Audit the spec for risks")
  → scope-audit-report.md (PASS / REVISE / ABANDON verdict)
  
  ↓ [GATE: PM confirms PASS]
  
@architect
  (Dev: "Design the system from approved spec")
  → tech-spec.md (component diagram, data flow, tradeoffs)
  
  ↓ [GATE: Dev adds approval marker]
  
@developer
  (Dev: "Implement the design with tests")
  → src/* (implementation), tests/* (test coverage)
  
  ↓ [Dev runs @self-check]
  
@self-check
  (AI: pre-handoff review)
  → Annotated diff (catches obvious issues)
  
  ↓ [Dev checks @self-check output]
  
@code-reviewer
  (Dev or AI: "Review for security/conventions")
  → review-report.md or PASS
  
  ↓ [GATE: Dev approves, ready to merge]
  
Ship ✅
```

### Quick Bug Fix Workflow

```
@developer
  (Dev: "Fix this bug")
  → Code fix + test
  
  ↓
  
@self-check + @code-reviewer
  (AI: pre-merge checks)
  → Review report or PASS
  
  ↓
  
Ship ✅
```

### High-Risk Change Workflow

```
@developer
  (Dev: "Implement auth overhaul")
  → Code + tests
  
  ↓
  
@self-check
  → Annotated diff
  
  ↓
  
@code-reviewer
  → review-report.md
  
  ↓
  
@quality-check
  (Dev: "Test these edge cases: [list]")
  → Test report (all cases pass)
  
  ↓
  
Ship ✅
```

### Resume After Context Switch

```
@session-memory
  (Both: "What did we do last session?")
  → memory.md (chronological log, decisions, next steps)
  
  ↓ [Read memory.md, understand state, continue from where you left off]
  
Next skill in workflow
```

---

## When to Pair Skills

Secondary skills are invoked *alongside* a primary skill, not instead of it.

| If you're doing... | Also invoke |
|----|---|
| Scoping any new feature | @scope-audit (mandatory gate) |
| Implementation of any kind | @self-check (pre-handoff) |
| Any code before shipping | @code-reviewer (pre-merge gate) |
| Auth, payments, migrations | @quality-check (edge case hunting) |
| Multi-day work or tool switch | @session-memory (state persistence) |
| Investigating a past failure | @session-memory (read logs to understand what happened) |

---

## Handoff Chain & Gates

```
@spec-writer       write spec.md
    ↓
  [GATE: PM approves]
    ↓
@scope-audit        write scope-audit-report.md (PASS/REVISE/ABANDON)
    ↓
  [GATE: PM confirms verdict]
    ↓
@architect          write tech-spec.md
    ↓
  [GATE: Dev approves]
    ↓
@developer          write code + tests
    ↓
@self-check         pre-handoff check (inline)
    ↓
@code-reviewer      write review-report.md or PASS
    ↓
  [GATE: Dev reviews]
    ↓
@quality-check      (only if high-risk) write test report
    ↓
  [GATE: All tests pass]
    ↓
Ship ✅
```

**No gate skipping. No proceeding without approval markers.**

---

## Skill Lifecycle

### Load-on-Demand Rule

- Do NOT load all 8 skills on session start
- Load ONLY AGENTS.md + CONVENTIONS.md at startup
- Load individual skill files immediately before adopting that role
- Unload after handoff (don't carry skill context across role boundaries)

**Why:** Keeps context window lean, prevents prompt bloat, improves consistency.

---

## Approval Markers

### In Artifact Files

```markdown
# Feature: User Comments

[content]

<!-- APPROVED by PM [Name], [date] [time] -->
```

### In .project/approvals.md

```markdown
## Feature: User Comments

### Spec Phase
- Status: APPROVED ✅
- Approved by: PM [Name], 2026-05-03 10:15 AM
- Notes: Scope looks good

### Audit Phase
- Status: PASS ✅
- Approved by: PM [Name], 2026-05-03 10:45 AM
- Notes: No blockers

### Architecture Phase
- Status: APPROVED ✅
- Approved by: Dev [Name], 2026-05-03 11:30 AM
- Notes: Uses existing PostgreSQL

### Code Phase
- Status: REVIEWED ✅
- Reviewed by: Dev [Name], 2026-05-03 2:00 PM
- Notes: Tests pass, conventions met
```

---

## Quick Reference: Which Skill to Load

| Question | Skill |
|---|---|
| "I have a vague feature idea" | @spec-writer |
| "I have a spec, need to check for risks" | @scope-audit |
| "Spec is approved, need architecture" | @architect |
| "Architecture done, ready to build" | @developer |
| "Code done, need quick review before handoff" | @self-check |
| "Pre-merge security/convention check" | @code-reviewer |
| "High-risk change, need edge case testing" | @quality-check |
| "What did we do last session?" | @session-memory |

---

## Artifact Locations

### Where Artifacts Live

```
docs/
├── specs/
│   ├── 2026-05-03-user-comments.md       [@spec-writer output + approval]
│   └── 2026-05-15-pagination.md
│
└── architecture/
    ├── system-design.md                  [Overall system architecture]
    ├── decisions/
    │   ├── ADR-0001-monolith-vs-services.md
    │   └── ADR-0002-database-strategy.md
    └── user-comments-design.md           [@architect output + approval]

.project/
├── approvals.md                          [Approval log]
├── metrics.md                            [Success metrics]
└── memory.md                             [@session-memory output]

scope-audit-report.md                     [@scope-audit output] (root level or docs/specs/)
review-report.md                          [@code-reviewer output] (root level or docs/)
```

---

## The 8 Skills: Detailed Reference

For detailed instructions for each skill, see:
- `skills/spec-writer/SKILL.md`
- `skills/scope-audit/SKILL.md`
- `skills/architect/SKILL.md`
- `skills/developer/SKILL.md`
- `skills/self-check/SKILL.md`
- `skills/code-reviewer/SKILL.md`
- `skills/quality-check/SKILL.md`
- `skills/session-memory/SKILL.md`

---

## Common Scenarios

### Scenario 1: Simple Feature (Low Risk)

```
Workflow: @spec-writer → @scope-audit (PASS) → @architect → @developer → @self-check → @code-reviewer → ship
Duration: 4-6 hours
When to use: New UI, new non-critical endpoint, data reporting
```

### Scenario 2: Bug Fix

```
Workflow: @developer → @self-check → @code-reviewer → ship
Duration: 15-60 min
When to use: Critical issue, production bug, regression
```

### Scenario 3: Auth or Payment Feature

```
Workflow: @spec-writer → @scope-audit (PASS) → @architect → @developer → @self-check → @code-reviewer → @quality-check (edge cases) → ship
Duration: Full day
When to use: High-risk changes, security-critical code, financial transactions
```

### Scenario 4: Multi-Session Refactor

```
Session 1: @architect (design refactor) → @developer (start implementation) → @session-memory (save progress)
Session 2: @session-memory (resume from log) → @developer (continue) → @self-check → @code-reviewer → ship
Duration: 2-3 sessions, spans days/weeks
When to use: Large refactors, complex migrations, multi-person handoffs
```

---

## Success Checklist

Use this to know when you're "done" with a feature:

- [ ] Spec written and approved
- [ ] Scope audit passed (verdict: PASS)
- [ ] Architecture designed and approved
- [ ] Code implemented and tests written
- [ ] @self-check run (no obvious issues)
- [ ] @code-reviewer passed (security, conventions OK)
- [ ] @quality-check passed (if applicable)
- [ ] PR reviewed by Dev + PM
- [ ] Merged to main
- [ ] Deployed to production (or staging, if staged)

---

## Tool Integration

Each skill reads these files:

- `AGENTS.md` — universal rules
- `CONVENTIONS.md` — team/project specifics
- Individual `SKILL.md` file (loaded on-demand)
- Relevant artifact files (spec.md, tech-spec.md, etc.)

All tools (Cursor, Claude Code, Copilot, Windsurf) read the same files via symlinks.

---

**Last updated:** 2026-05-03

**For questions:** See README.md or open an issue.
