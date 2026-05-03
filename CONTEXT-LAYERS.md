# Context Layers: The 6-Layer AI Agent Context Model

**Purpose:** Understand the full stack of context that makes AI agents effective. Each layer builds on the previous one. Each layer requires different governance.

---

## The 6 Layers (From Infrastructure to Execution)

### Layer 1: AGENTS.md — Workflow Rules (LAF Provides ✅)

**What it is:** Universal rules governing how AI assistants should behave on your codebase.

**What it covers:**
- Approval gates and handoff protocols
- Decision-making principles (simplest solution first, name the tradeoff)
- Skill precedence and conflict resolution
- Artifact locations and naming conventions

**Governance:** 
- **Written by:** Architect / Framework owner
- **Updated by:** Team lead (rarely, once established)
- **Scope:** Applies across ALL projects using LAF
- **When to customize:** Almost never. AGENTS.md is your baseline.

**Example rules in AGENTS.md:**
- Rule 1: Simplest Solution First
- Rule 2: Read Before You Write
- Rule 3: One Thing at a Time
- Rule 8: Approval Gates Are Non-Negotiable

---

### Layer 2: Path-Scoped Rules — Project-Specific Patterns (LAF Provides Template ✅)

**What it is:** Context that applies only to specific file types or directories in your project.

**What it covers (you decide):**
- Controllers use dependency injection (not singletons)
- All `components/` have JSDoc
- API routes require auth middleware
- Database models must have migrations
- Tests must cover happy path + 2 error cases

**Governance:**
- **Written by:** Dev lead (at project start)
- **Updated by:** Team (as patterns emerge)
- **Scope:** One `.cursor/rules/` entry per pattern
- **When to customize:** Reactively, as you discover repeating patterns

**How to implement:**
```
.cursor/rules/
├── controllers.md      (must use dependency injection)
├── database.md         (migration required before merge)
├── api-routes.md       (auth middleware on all routes)
└── testing.md          (80% coverage minimum)
```

**Location in LAF:** See `CONVENTIONS.md` for the template framework.

---

### Layer 3: Skills — Role-Specific Workflows (LAF Provides ✅)

**What it is:** Specialized instruction sets for each role in your workflow.

**What it covers:**
- `@spec-writer` — how to write a spec that's auditable
- `@scope-audit` — what risks to look for
- `@architect` — design template and tradeoff documentation
- `@developer` — implementation checklist
- `@self-check` — pre-handoff review workflow
- `@code-reviewer` — security + convention gates
- `@quality-check` — edge case testing strategy

**Governance:**
- **Written by:** Framework owner (LAF)
- **Updated by:** Team (feedback → new skill or modified skill)
- **Scope:** Loaded on-demand by role
- **When to customize:** When a role has project-specific gates (e.g., "all PRs need InfoSec approval")

**Location in LAF:** `skills/<skill-name>/SKILL.md`

---

### Layer 4: MCP Servers — External Tool Integration (Team Decides 🤔)

**What it is:** Live connections to external tools and APIs that the agent queries in real time instead of relying on training data.

**What it covers (examples):**
- Datadog (logs, metrics, alerts)
- Slack (team decisions, deployment notifications)
- GitHub / GitLab (PR history, CI status, deployment history)
- Linear / Jira (scope tracking, acceptance criteria)
- Databases (schema, test data, migrations)
- Confluence / Notion (documentation, design specs)

**Governance:**
- **Written by:** Dev lead
- **Updated by:** Team (as tools change)
- **Scope:** Project-specific MCP configuration
- **When to customize:** When you add a new external tool to your workflow

**How to implement:**
```
# For Cursor projects, in project root:
.cursor/mcp.json          (MCP server configuration)
.env.mcp                  (API keys for MCP tools)

# Example:
{
  "mcpServers": {
    "datadog": {
      "command": "node",
      "args": ["path/to/mcp-datadog.js"],
      "env": { "DD_API_KEY": "from .env.mcp" }
    },
    "github": { ... }
  }
}
```

**Examples from the field:**
- **High-context teams:** Wire Slack + GitHub + Linear → agent sees PR comments, Slack decisions, and issue scope automatically
- **Data teams:** Wire Databricks + Postgres + Sentry → agent can query production data, run notebooks, see error traces
- **Minimal teams:** No MCP servers → agent works from code and conversations only (slower, but no setup)

**Decision point:** Do you need real-time access to external tools, or can the team provide context manually in chat?

---

### Layer 5: Clean Codebase — Structural Context (Team Decides 🤔)

**What it is:** How your code is organized, named, and documented. This makes the codebase itself readable to agents.

**What it covers (examples):**
- **Naming conventions:** Functions describe behavior (`getUserByEmail` not `fn`), files map to features (`auth.ts` not `util.ts`)
- **File organization:** Related code in same directory, clear structure (no "misc" folders)
- **Documented decisions:** ADRs in `docs/architecture/decisions/`, not just in code comments
- **Module boundaries:** Clear separation of concerns (API layer vs. business logic vs. database layer)
- **Comments:** Only non-obvious intent (why, not what; no `// increment counter`)

**Governance:**
- **Written by:** Architect / Dev lead (at project start)
- **Updated by:** Team (via code review)
- **Scope:** Project-specific code quality standards
- **When to customize:** At project start; rarely updated after

**How to implement:**

Create `.project/codebase-health.md` (or add to `CONVENTIONS.md`):

```markdown
## Codebase Health Standards

### Naming
- Functions: verb + noun (getUserByEmail, formatDate, validateSchema)
- Files: lowercase, kebab-case, noun (user-service.ts not UserService.ts)
- Directories: plural, kebab-case (components/, utils/, routes/)

### File Organization
- API routes in src/routes/ with auth middleware explicit
- Business logic in src/services/ (no controller logic there)
- Type definitions in src/types/ or colocated with implementation
- Tests adjacent to code: src/lib/utils.ts + src/lib/utils.test.ts

### Documented Decisions (ADRs)
- Every non-obvious architectural choice gets an ADR
- Location: docs/architecture/decisions/ADR-NNNN-*.md
- Format: Problem, Solution, Tradeoffs, Consequences

### Module Boundaries
- src/api/ — HTTP layer only (routing, parsing, status codes)
- src/services/ — Business logic (no HTTP knowledge)
- src/db/ — Data access (no business logic)
- src/types/ — Shared types across layers

### Code Comments
- DO: Explain "why" (tradeoff, constraint, non-obvious decision)
- DON'T: Explain "what" (code already says what it does)
- Example DO: "Cache for 5m because upstream API rate-limits at 1000/min"
- Example DON'T: "// Get the user" above const user = getUserByEmail()
```

**Decision points:**
1. How strict is your naming? (bikeshed vs. enforce)
2. Do you use ADRs for decisions?
3. What are your file organization rules?

---

### Layer 6: Test Suite — Verification Context (Team Decides 🤔)

**What it is:** Automated tests that tell the agent what correct behavior looks like and catch mistakes.

**What it covers (examples):**
- Unit tests: individual functions (80% coverage minimum)
- Integration tests: layer boundaries (API + DB)
- E2E tests: user workflows (critical paths only)
- Pre-commit hooks: tests run before pushing
- CI/CD gates: tests must pass before merge
- Test data strategy: fixtures, factories, seed data

**Governance:**
- **Written by:** Dev (alongside feature code)
- **Updated by:** Team (as coverage gaps appear)
- **Scope:** Project-specific test requirements
- **When to customize:** At project start; revisit every quarter

**How to implement:**

Create `.project/test-requirements.md` (or add to `CONVENTIONS.md`):

```markdown
## Test Requirements

### Coverage & Scope
- Minimum coverage: 80% (branches, not just lines)
- Unit tests: All business logic
- Integration tests: Layer boundaries (API↔DB, service↔external API)
- E2E tests: Top 5 user flows only (maintenance cost is high)

### Test Location & Structure
- Unit tests: Adjacent to code (src/lib/utils.test.ts)
- Integration tests: tests/integration/
- E2E tests: tests/e2e/ (if applicable)
- Test data: tests/fixtures/ (reusable test objects)

### Pre-Commit & CI Gates
- Pre-commit hook: Run tests locally before push (fail if <80%)
- CI gate: `npm run test:ci` must pass before merge
- Failing test = PR blocked (no exceptions)

### High-Risk Areas (100% Required)
- Auth & access control
- Payment processing
- Data deletion / migration
- Security filters

### Test Naming
- Describe the scenario: "should reject login with invalid password"
- Not: "test login" or "test error"
```

**Decision points:**
1. What's your coverage target? (70%, 80%, 90%?)
2. Do you write tests first (TDD) or after?
3. Are E2E tests worth the maintenance cost for your project?
4. Do pre-commit hooks run tests? (slows down commits but catches early)

---

## How the 6 Layers Work Together

```
Layer 1 (AGENTS.md)
  ↓ Defines global rules
Layer 2 (Path-scoped rules)
  ↓ Applies rules to specific directories
Layer 3 (Skills)
  ↓ Each skill references Layers 1–2, provides role-specific workflow
Layer 4 (MCP servers)
  ↓ Agent queries real-time data from external tools
Layer 5 (Clean codebase)
  ↓ Agent reads your code, understands structure and intent
Layer 6 (Test suite)
  ↓ Agent runs tests to verify correctness; tests guide agent behavior
```

**Example: Agent writes a feature**
1. Consults Layer 1 (AGENTS.md) — "What are my approval gates?"
2. Consults Layer 2 (path rules) — "What conventions apply to `src/services/`?"
3. Follows Layer 3 (developer skill) — "Here's the build workflow"
4. Queries Layer 4 (MCP) — "What does the schema look like?" (from Postgres MCP)
5. Reads Layer 5 (codebase) — "How are other services structured?"
6. Runs Layer 6 (tests) — "Did my code pass the test suite?"

Each layer informs the next.

---

## Onboarding a New Project to LAF

**Minimum viable context (1 day):**
1. Copy AGENTS.md + CONVENTIONS.md into project root
2. Teams reads AGENTS.md once (understand approval gates)
3. Team customizes CONVENTIONS.md (stack, style, commands)
4. Done. Start using LAF.

**Recommended context (1 week):**
1. Do the minimum (above)
2. Add Layer 2: Create `.cursor/rules/` for observed patterns
3. Add Layer 5: Write `codebase-health.md` (naming, file structure, ADRs)
4. Add Layer 6: Define test requirements (coverage %, where tests live)

**Ideal context (2 weeks, first project only):**
1. Do recommended (above)
2. Add Layer 4: Wire MCP servers for tools your team uses (Slack, GitHub, Datadog, etc.)
3. Set up pre-commit hooks to run tests
4. Document decisions in ADRs as they happen

---

## Template: Layer Decision Checklist

**To onboard a new project, copy this and fill it out:**

```markdown
## Project Context Layers

### Layer 1: AGENTS.md
- [ ] Copied from LAF into project root
- [ ] Team has read it once
- Status: ✅ (always required by LAF)

### Layer 2: Path-Scoped Rules
- [ ] Created `.cursor/rules/` directory
- [ ] Documented 3–5 key patterns (e.g., auth, database, components)
- Examples: [list your rules here]
Status: [Planned / In Progress / Complete]

### Layer 3: Skills
- [ ] Using LAF's 8 skills as-is
- [ ] Or customized for project-specific gates (list below)
Customizations: [none / list here]
Status: ✅ (LAF provides)

### Layer 4: MCP Servers
- [ ] No MCP integration needed (team provides context manually)
- [ ] Using MCP for: [Slack / GitHub / Datadog / Linear / other]
- [ ] MCP configuration: `.cursor/mcp.json` and `.env.mcp` created
Status: [Not needed / Planned / In Progress / Complete]

### Layer 5: Clean Codebase
- [ ] Created `.project/codebase-health.md` with:
  - [ ] Naming conventions
  - [ ] File organization rules
  - [ ] ADR process documented
  - [ ] Module boundary definitions
Status: [Planned / In Progress / Complete]

### Layer 6: Test Suite
- [ ] Created `.project/test-requirements.md` with:
  - [ ] Coverage target (%)
  - [ ] Test location structure
  - [ ] Pre-commit hook (yes / no)
  - [ ] CI gate requirements
  - [ ] High-risk areas (100% required)
Status: [Planned / In Progress / Complete]
```

---

## FAQ

**Q: Do I need all 6 layers?**

A: No. Layers 1–3 are LAF's domain (you always get them). Layers 4–6 are team decisions. Start with what you need:
- **Minimal team (solo dev):** Layers 1–3 only.
- **Growing team (2–3 devs):** Add Layer 5 (codebase health) so new devs understand structure.
- **External dependencies (APIs, DBs, CI):** Add Layer 4 (MCP) for real-time context.
- **High-risk code (auth, payments):** Add Layer 6 (tests) with strict coverage.

**Q: Can I skip Layer 5 (codebase health)?**

A: You can, but don't. Agents are dramatically more effective when your code is well-named and organized. It costs 4 hours to write `codebase-health.md` once; it saves 20+ hours of agent confusion per month.

**Q: How do I keep Layers 4–6 in sync?**

A: They live in Git with your code. Review them in sprints:
- **Layer 4:** Updated when you add / remove external tools
- **Layer 5:** Updated when naming patterns shift (quarterly)
- **Layer 6:** Updated when coverage gaps appear (in PR review)

**Q: What if my team uses different tools (Cursor vs. Claude vs. Copilot)?**

A: All 6 layers are tool-agnostic. Each tool reads the same AGENTS.md, CONVENTIONS.md, and test suite. Layer 4 (MCP) is tool-specific, but the principle is the same: wire your external tools for real-time context.

---

## Next Steps

1. **Read this doc once** — bookmark it as your context layer reference
2. **For a new project:** Fill out the Layer Decision Checklist above
3. **For an existing project:** Assess where you stand on each layer
4. **Start simple:** Layer 1 only (AGENTS.md + CONVENTIONS.md), add Layers 4–6 as pain points emerge

---

**Key Principle:** Context layers are not overhead. They are how you make AI agents work for you. Without them, each agent reinvents how to behave. With them, all agents on the team follow the same playbook.

**Citation:** This 6-layer model is grounded in research on how humans transfer context. Each layer addresses a different problem:
- Layer 1: Rule coherence (what should the agent do?)
- Layer 2: Pattern recognition (what's the standard here?)
- Layer 3: Role clarity (what's my job right now?)
- Layer 4: Data accuracy (what's the current state?)
- Layer 5: Code readability (what does this code mean?)
- Layer 6: Correctness verification (did I get it right?)
