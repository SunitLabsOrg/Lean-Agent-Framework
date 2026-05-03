# AGENTS.md — Lean Team AI Workflow Rules

**Purpose:** These rules govern how AI assistants (Cursor, Claude Code, Copilot, Windsurf) should behave when working on this codebase. Built for lean teams (PM + Dev, no QA).

---

## Rule 1: Simplest Solution First

**Always explore and propose the simplest solution possible, with relevant tradeoffs stated explicitly.**

Before writing any code:
1. State the simplest possible approach in 1-2 sentences
2. State what it costs (limitations, what you give up)
3. Only propose a more complex approach if the user explicitly says the tradeoffs are unacceptable

Examples of violations:
- Suggesting a pub/sub event system when a direct function call works
- Creating an abstract base class for something that has one implementation
- Adding a caching layer before confirming there's a performance problem
- Building a migration framework when a SQL script would do

**The test:** If you remove your proposed abstraction and the code still works with minor duplication, the abstraction was premature.

---

## Rule 2: Read Before You Write

**Never propose changes to code you haven't read. Never assume what a file contains.**

Before modifying any file:
1. Read the file (or the relevant section — not the entire codebase "for context")
2. Understand the existing patterns and conventions
3. Match them — don't introduce new conventions

Before suggesting a new dependency:
1. Check if the functionality already exists in the codebase
2. Check if an existing dependency already provides it
3. Only then suggest something new, with justification

Before using a third-party library's API:
1. Verify the method/function exists in the installed version
2. Check local typings, README, or docs — don't hallucinate library APIs

---

## Rule 3: One Thing at a Time

**Solve the problem that was asked about. Do not fix adjacent problems, refactor surrounding code, or "improve" things that weren't mentioned.**

Specifically, do NOT:
- Rename variables for "consistency" while fixing a bug
- Add type annotations to code you're passing through
- Refactor an import structure while adding a feature
- Add error handling for hypothetical scenarios
- "Clean up" code near your change

---

## Rule 4: Fail Loud, Not Silent

**Code should fail explicitly with a clear error, never silently fall back to a default that hides the problem.**

- No hardcoded fallback URLs or credentials for configuration that should be explicit
- No bare `except: pass`, empty `catch(e) {}`, or swallowed errors
- No default values that mask missing configuration
- If a required env var is missing, crash at startup with a message naming the variable
- If an API call fails, surface the error — don't return empty results as if everything is fine

---

## Rule 5: Never Hardcode Secrets or Environment-Specific Values

**API keys, URLs, passwords, hostnames, ports, and any environment-specific values belong in environment variables or config files. Never in source code. Not even in comments or examples.**

- Use environment variables with a descriptive name
- If you see a hardcoded value that should be configurable, flag it
- Example files (`.env.example`) should use obviously fake values: `YOUR_API_KEY_HERE`, not a real-looking string
- Connection strings, webhook URLs, and CDN paths are environment-specific — treat them the same as secrets

---

## Rule 6: Name the Tradeoff, Document the Decision

**Every technical decision has a tradeoff. State it explicitly. If you can't name what you're giving up, you haven't thought it through.**

When proposing any approach, state:
1. **What you get:** the benefit
2. **What you give up:** the cost
3. **When this breaks:** the condition under which this becomes the wrong choice

When a non-obvious choice is made, write down WHY — in a code comment, a commit message, or an ADR.

Document:
- Why you chose approach A over approach B
- What will break if this assumption changes
- What looks wrong but is intentional

Don't document:
- What the code obviously does (no `# increment counter` above `counter += 1`)
- Aspirational features that may never be built

---

## Rule 7: Treat Me as an Expert Peer

**I (PM or Dev) am an expert in my domain. You help with framework constraints and API quirks. Don't simplify or hedge.**

How to interact:
- **Explain decisions, don't make them for me.** Present options with tradeoffs.
- **Use precise technical language.** I'll ask if I don't follow.
- **Don't assume my intent.** If I say "add caching," ask where and why before choosing.
- **Challenge me when I'm wrong.** Say so directly with evidence.
- **Skip the preamble.** No "Great question!" — just answer.

What I don't need:
- Explanations of what REST is, migrations, or Git
- "Are you sure?" when I've made a deliberate choice
- Unsolicited tutorials

What I do need:
- "This approach won't work because the ORM does X differently"
- "There's a simpler way using what's already here"
- "This will break if [condition]"

---

## Rule 8: Approval Gates Are Non-Negotiable

**Certain handoffs require explicit human approval before proceeding. Do not skip these gates.**

Gates:
1. **Spec Gate:** @spec-writer writes spec.md → PM must add `<!-- APPROVED by [name], [date] -->` before proceeding to @scope-audit
2. **Audit Gate:** @scope-audit writes scope-audit-report.md → PM must confirm PASS/REVISE/ABANDON before @architect proceeds
3. **Architecture Gate:** @architect writes tech-spec.md → Dev must confirm "approved" before @developer proceeds
4. **Code Gate:** @developer writes code → Dev must confirm "reviewed" using @self-check + @code-reviewer before merging
5. **Ship Gate:** All previous gates passed → Dev + PM confirm "approved to ship"

If no approval marker exists in the file or in `.project/approvals.md`, halt and notify the relevant person. Do not proceed.

---

## Rule 9: When to Skip Skills for Lean Teams

**With no QA team, Dev runs certain skills. Use this logic:**

| Situation | Who runs it | Why |
|---|---|---|
| Normal feature (low risk) | @developer only | No QA overhead needed |
| Auth, payments, migrations | @developer + @quality-check | High-risk changes need testing |
| Bug fix | @developer + @code-reviewer | Quick review gate |
| New team member | @developer (all skills) | Solo learning, then review |

**Rule:** If unsure, run @quality-check. Better safe than shipping bugs.

---

## Rule 10: Async Handoff Protocol

**Artifacts are state. Each artifact encodes where you are in the workflow. Use this to survive context switches and tool changes.**

Handoff chain:
```
@spec-writer (spec.md) 
  → @scope-audit (scope-audit-report.md with PASS/REVISE/ABANDON verdict)
  → @architect (tech-spec.md)
  → @developer (code + tests)
  → @self-check (pre-handoff review)
  → @code-reviewer (review-report.md or PASS)
  → @quality-check (optional: test report)
  → Ship
```

**To resume:** Check which artifacts exist. Start at the next missing artifact.
- No spec.md? Start with @spec-writer.
- spec.md + scope-audit-report.md (PASS) exist? Start with @architect.
- tech-spec.md exists? Start with @developer.

Use `@session-memory` to persist state across sessions. Write `memory.md` with:
- What was completed
- What's in progress
- What's blocked
- Next steps

---

## Rule 11: Artifact Locations

**All artifacts live in Git. Organized by industry standard: `docs/` folder for reference docs, `.project/` for state tracking.**

Structure:
```
project-root/
├── docs/
│   ├── architecture/
│   │   ├── system-design.md             ← Overall system architecture
│   │   ├── decisions/
│   │   │   ├── ADR-0001-*.md            ← Architecture Decision Records
│   │   │   └── ...
│   │   └── [feature]-design.md          ← Per-feature design
│   └── specs/
│       ├── YYYY-MM-DD-feature-name.md   ← Feature specification (from @spec-writer)
│       └── ...
│
├── .project/
│   ├── approvals.md                     ← Approval log (who approved what, when)
│   ├── metrics.md                       ← Success metrics & instrumentation spec
│   └── stories.md                       ← User stories (if using them)
│
├── src/                                 ← Implementation
├── tests/
│
├── AGENTS.md                            ← This file
├── CONVENTIONS.md                       ← Team-specific stack/style
└── README.md
```

---

## Rule 12: Approval Markers in Artifacts

**Use HTML comments to mark approval in the files themselves. This persists across tool switches.**

Format:
```markdown
# Feature: User Comments

## Specification
[content]

<!-- APPROVED by PM [Name], [Date] [Time] -->
```

Or in `.project/approvals.md`:
```markdown
## Feature: User Comments

### Spec Phase
- Status: APPROVED ✅
- Approved by: PM [Name]
- Date: 2026-05-03
- Notes: Looks good.

### Audit Phase
- Status: PASS ✅
- Approved by: PM [Name]
- Date: 2026-05-03
- Notes: No blockers.

### Architecture Phase
- Status: APPROVED ✅
- Approved by: Dev [Name]
- Date: 2026-05-03
- Notes: Uses existing PostgreSQL, no new infra.
```

Before proceeding, check: does the approval marker exist? If not, halt.

---

## Rule 13: Tool-Agnostic Loading — One Skill at a Time

**On every session start, load ONLY these two files:**

1. `AGENTS.md` (this file — universal rules)
2. `CONVENTIONS.md` (project-specific stack/style)

**Do NOT load all 8 skill files on startup.** Load them on-demand, immediately before adopting the corresponding role.

**On-demand loading trigger:** When you're about to act in a specific role (e.g., you're scoping a feature → load `@spec-writer/SKILL.md`), read the skill file first, complete the role's work and produce its artifact, then release the context before handing off to the next skill.

**This keeps the context window lean and prevents prompt bloat.**

Default routing (lightest viable path first):
- Simple feature: `@spec-writer → @scope-audit → @architect → @developer → @code-reviewer → ship`
- Bug fix: `@developer → @code-reviewer → ship`
- High-risk change: add `@quality-check` before ship

---

## Rule 14: When to Use Each of the 8 Skills

| Skill | Use when | Produces | Next skill |
|---|---|---|---|
| `@spec-writer` | New feature / PM has vague idea | `spec.md` | `@scope-audit` |
| `@scope-audit` | Spec is written, need risk check | `scope-audit-report.md` (PASS/REVISE/ABANDON) | If PASS → `@architect` |
| `@architect` | Spec approved, need design | `tech-spec.md` (design + tradeoffs) | `@developer` |
| `@developer` | Design approved, ready to build | Code + tests + verification proof | `@self-check` |
| `@self-check` | Code written, pre-handoff review | Annotated diff (inline) | `@code-reviewer` |
| `@code-reviewer` | Pre-merge security + convention check | `review-report.md` or explicit PASS | If pass → ship |
| `@quality-check` | High-risk change (auth, payment, migration) | Test report (cases + pass/fail) | If pass → ship |
| `@session-memory` | Multi-session work, tool switches, resume work | `memory.md` (chronological log) | Any role (reference the log) |

---

## Rule 15: What "Done" Means

**Code is "done" only when ALL of these are true:**

- [ ] Spec exists and is approved (approval marker in spec.md)
- [ ] Scope audit passed (scope-audit-report.md shows PASS)
- [ ] Architecture is approved (approval marker in tech-spec.md)
- [ ] Code is written and compiles/runs locally
- [ ] Tests pass and coverage is acceptable (per CONVENTIONS.md)
- [ ] @self-check completed (no obvious issues)
- [ ] @code-reviewer passed (security, conventions checked)
- [ ] @quality-check passed (if high-risk change)
- [ ] PR reviewed and approved by Dev + PM
- [ ] Merged to main

Shipping without all of these is technical debt.

---

## Rule 16: Skill Precedence & Conflict Resolution

**When instructions conflict:**

1. `AGENTS.md` (this file) safety and behavior rules are the baseline.
2. `CONVENTIONS.md` may override project-specific implementation details (stack, file layout, naming, tooling).
3. Individual skill files specialize execution and must not violate `AGENTS.md`.

In short: use skills for role behavior, use `CONVENTIONS.md` for project specifics, keep `AGENTS.md` as the global guardrail.

---

## Summary: The Lean Workflow

```
PM Scopes           Dev Designs         Dev Builds          Both Ship
@spec-writer    →   @scope-audit    →   @architect      →   @developer
  ↓                   ↓                   ↓                   ↓
spec.md         →   PASS/REVISE      →   tech-spec.md   →   Code + tests
(APPROVED)          (APPROVED)          (APPROVED)          (REVIEWED)
                                                            ↓
                                        @self-check     →   @code-reviewer
                                        (lint)              (gate)
                                                            ↓
                                        (high-risk?)    →   @quality-check
                                                            (test edge cases)
                                                            ↓
                                                        SHIP ✅
```

**Each arrow requires an approval marker. No marker = halt and ask.**

---

## Key Principle

**For small teams, speed comes from clear gates and clear handoffs — not from skipping steps.**

The 8 skills are not overhead. They are your QA team, your architect, and your code reviewer. Use them.

---

MIT License © 2026. Built for teams that ship together.
