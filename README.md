# Lean Agent Framework (LAF)

**Build at the speed of decision. For lean teams.**

Start with **this README** for overview and setup; use **[INDEX.md](INDEX.md)** for skills, workflows, and gates; **[CONTEXT-LAYERS.md](CONTEXT-LAYERS.md)** for the 6-layer model; **[AGENTS.md](AGENTS.md)** and **[CONVENTIONS.md](CONVENTIONS.md)** live in your project (copy from `.laf/`) and are what your AI tools load, together with **`skills/*/SKILL.md`**.

A lightweight, tool-agnostic AI workflow framework for small teams (PM + Dev, no QA). Use it to keep multiple AI tools (Cursor, Claude Code, Copilot, Windsurf) working consistently on the same codebase, with built-in approval gates and artifact tracking.

**Inspired by:** [Virtual Product Factory](https://github.com/vshrinath/virtual-product-factory) (VPF), simplified for lean teams.

---

## Documentation map

Read these in order the first time; bookmark **INDEX.md** for day‑to‑day routing.

| Document | Purpose |
|----------|---------|
| **[README.md](README.md)** | What LAF is, install, symlink setup, first feature |
| **[CONTEXT-LAYERS.md](CONTEXT-LAYERS.md)** | The 6-layer agent context model (understand what LAF provides and what your team builds) |
| **[INDEX.md](INDEX.md)** | Skill index: workflows, gates, scenarios, artifact locations |
| **[AGENTS.md](AGENTS.md)** | Rules every AI assistant must follow (16 rules) |
| **[CONVENTIONS.md](CONVENTIONS.md)** | Your stack, style, and commands (**customize** in your project root) |

---

## Why This Exists

### Problem 1: Multi-Tool Drift (Today)

When your PM and Dev use different AI tools on the same project:
- Each tool invents its own patterns and structure
- Specs drift from code
- Context is lost between tool switches
- Approvals are scattered across PR threads and chat history

### Problem 2: Tool Migration Chaos (Over Time)

When your organization evaluates and switches AI tools:
- **Year 1:** "We standardize on Copilot" → team builds conventions
- **Year 2:** "We're switching to Cursor" → conventions lost, reinvented differently
- **Year 3:** "We're adding Claude" → new people have no idea what standards apply
- **Year 4:** "Windsurf looks good too" → another tool, another learning curve

Each tool change triggers weeks of confusion, re-training, and pattern reinvention.

**Real Example:** Your organization used Copilot (Year 1), switched to Cursor (Year 2), and is now onboarding Claude Code and Windsurf (Year 3). Without a stable rulebook, each tool switch reset the team's conventions. New Claude users didn't know your standards. Windsurf evaluation meant starting from scratch again.

### Solution: Tool-Agnostic Framework

LAF separates **tool** from **workflow**:

- **Workflow rules** (`AGENTS.md`, `CONVENTIONS.md`) live in Git, version-controlled
- **All tools read the same rules** via symlinks (Cursor, Claude, Copilot, Windsurf, others)
- **Tool switches are friction-free** — update symlink, done
- **Onboarding new people:** Read `AGENTS.md` once, works with any tool

**Result:**
- Tool migrations: 1-day transition (not 3 weeks)
- Consistency: Patterns survive tool changes
- Future-proof: Tools will come and go; your workflow stays stable
- **This is how you escape tool vendor lock-in.**

---

## What You Get

### 8 Core Skills (Not 32)

Focused on lean teams:

| Skill | Role | For whom | Produces |
|---|---|---|---|
| `@spec-writer` | Translate idea → spec | PM | `spec.md` |
| `@scope-audit` | Audit spec for risks | PM | `scope-audit-report.md` (PASS/REVISE/ABANDON) |
| `@architect` | Design system | Dev | `tech-spec.md` |
| `@developer` | Build code + tests | Dev | Implementation + tests |
| `@self-check` | Pre-handoff review | Dev | Annotated diff |
| `@code-reviewer` | Security + conventions | Dev | `review-report.md` or PASS |
| `@quality-check` | Edge case testing | Dev | Test report |
| `@session-memory` | Persist state | Both | `memory.md` |

### Core documents

1. **`AGENTS.md`** — Universal rules for all AI tools (16 rules, ~357 lines)
2. **`CONVENTIONS.md`** — Your team's stack/style decisions (customize this)
3. **`INDEX.md`** — Skill reference: workflows, gates, scenarios (`skills/*/SKILL.md` for full prompts)
4. **8 × `skills/<name>/SKILL.md`** — Role prompts loaded on demand

### Where everything lives

| Need | Location |
|---|---|
| Workflow rules every tool must follow | `AGENTS.md` (copied into **your project** root) |
| Stack, style, commands (you own this) | `CONVENTIONS.md` |
| Skill / workflow diagrams | **`INDEX.md`** |
| Full prompt / handoffs for one role | `skills/<skill-name>/SKILL.md` |
| How approval gates work | `templates/APPROVAL-WORKFLOW.md` |
| Example spec & design | `examples/sample-spec.md`, `examples/sample-tech-spec.md` |

---

## Quick Start

### 1. Initialize in Your Project

```bash
# Clone or download the framework
git clone https://github.com/your-org/lean-agent-framework.git .laf
cd your-project

# Copy core files
cp .laf/AGENTS.md .
cp .laf/CONVENTIONS.md .

# Set up tool integrations (creates symlinks so all tools read same AGENTS.md)

# Linux/Mac:
bash .laf/setup.sh --tools cursor,claude,copilot,windsurf

# Windows (PowerShell):
powershell -ExecutionPolicy Bypass -File .laf/setup.ps1 -tools "cursor,claude,copilot,windsurf"
```

> Note: this step creates symlinks. Run PowerShell as Administrator or enable
> Windows Developer Mode before executing it.

### 2. Customize `CONVENTIONS.md`

Edit your project's `CONVENTIONS.md`:

```markdown
# Your Stack
- Language: TypeScript
- Framework: Next.js
- DB: PostgreSQL
- Deployment: Vercel

# File Structure
- Code: src/
- Tests: tests/
- Specs: docs/specs/

# Ask Before Doing
- Database migrations
- Authentication changes
- Breaking API changes
```

### 3. Create Your First Feature

**PM (using Cursor or Claude Code):**
```
Cursor: "Scope this feature using @spec-writer: [idea]"
→ Cursor writes: docs/specs/2026-05-03-user-comments.md
→ PM reads, adds approval comment
```

**Dev:**
```
Cursor: "Audit the spec using @scope-audit"
→ Cursor writes: scope-audit-report.md (verdict: PASS)

Cursor: "Design the system using @architect, from the approved spec"
→ Cursor writes: docs/architecture/user-comments-design.md
→ Dev reviews, adds approval

Cursor: "Implement from approved tech-spec using @developer"
→ Cursor writes: code + tests (src/comments/*, tests/*)
→ Dev uses @self-check and @code-reviewer before committing
```

**Merge:**
```
git add docs/specs/ docs/architecture/ src/ tests/
git commit -m "feat: add user comments"
git push origin feature/user-comments
# Create PR, merge when both Dev and PM approve
```

---

## Supported AI Tools

All tools read the same `AGENTS.md` via symlinks:

| Tool | Status | Config File | Symlink |
|---|---|---|---|
| **Cursor** | ✅ Active | `.cursorrules` | → `AGENTS.md` |
| **Claude Code** | ✅ Active | `.claude.md` | → `AGENTS.md` |
| **Copilot** | ✅ Supported | `.github/copilot-instructions.md` | → `AGENTS.md` |
| **Windsurf** | ✅ Supported | `.windsurfrules` | → `AGENTS.md` |
| **Kiro** | ✅ Supported | `.kiro/steering/agents.md` | → `AGENTS.md` |
| **Other tools** | ⚠️ Manual | (create similar symlink) | → `AGENTS.md` |

**Key:** Every tool reads the same `AGENTS.md`. One file edit, all tools updated.

---

## Tool Migration: Copilot → Cursor → Claude → ?

### The Problem (Without LAF)

Your organization's real journey:

**Copilot Era (Year 1)**
- Team used Copilot exclusively
- Conventions were built (mostly in people's heads)
- Approvals happened in chat
- Code patterns were Copilot-flavored

**Cursor Era (Year 2)**
- "Let's switch to Cursor for better context"
- Copilot conventions were lost or forgotten
- Cursor users invented new patterns
- Code drifted from Copilot era code
- 2-week onboarding for Cursor users
- Frustration: "Why did we change our patterns again?"

**Claude/Windsurf Era (Year 3)**
- "Let's evaluate Claude Code and Windsurf"
- No clear standards (which tool uses which pattern?)
- Onboarding took 3+ weeks per tool
- Code quality inconsistent
- Conversations in Slack: "Wait, what are our conventions again?"

**Result:** Every tool switch reset the team's muscle memory and conventions.

### The Solution (With LAF)

**Copilot Era (Year 1)**
```
Write standards to AGENTS.md + CONVENTIONS.md
ln -sf AGENTS.md .copilot-config
Team reads AGENTS.md, understands workflow
```

**Cursor Era (Year 2)**
```
Decide to switch to Cursor
Update symlink: ln -sf AGENTS.md .cursorrules
Team continues work (AGENTS.md didn't change)
0-day transition
```

**Claude/Windsurf Era (Year 3)**
```
Evaluate Claude Code: ln -sf AGENTS.md .claude.md
Evaluate Windsurf: ln -sf AGENTS.md .windsurfrules
Both read same rules, same conventions
Onboarding: "Read AGENTS.md (already familiar)"
1-hour onboarding vs. 3 weeks
```

**Key Insight:** Tool switching is no longer a cultural reset. It's infrastructure configuration.

---

### The Workflow

```
Write Spec → Audit Risk → Design System → Build Code → Self-Check → Code Review → Quality Check → Ship
  (@spec-writer) (@scope-audit) (@architect) (@developer) (@self-check) (@code-reviewer) (@quality-check)
```

### Approval Gates

Each handoff requires an approval marker in the artifact:

```markdown
# Feature: User Comments

## Spec
...

<!-- APPROVED by PM, 2026-05-03 10:15 AM -->
```

The agent checks for this marker before proceeding. If it's missing, it halts and asks for approval.

### Artifact Locations (Industry Standard)

```
project-root/
├── docs/
│   ├── architecture/
│   │   ├── system-design.md      ← Overall system
│   │   ├── decisions/
│   │   │   ├── ADR-0001-*.md     ← Architecture decisions
│   │   │   └── ...
│   │   └── user-comments-design.md
│   └── specs/
│       ├── 2026-05-03-user-comments.md
│       ├── 2026-05-15-pagination.md
│       └── ...
│
├── .project/
│   ├── approvals.md              ← Approval log
│   ├── metrics.md                ← Success metrics
│   └── stories.md                ← User stories (optional)
│
├── src/                          ← Implementation
├── tests/
│
├── AGENTS.md                     ← The rulebook
├── CONVENTIONS.md                ← Your customizations
└── README.md
```

---

## For PM: How to Use This

### Scoping a Feature

1. Open Cursor or Claude Code
2. Prompt: `"I need you to act as @spec-writer. Scope this feature: [your idea]"`
3. Agent writes `docs/specs/YYYY-MM-DD-feature-name.md`
4. You read it (5 min)
5. If it looks good: add this to the file:
   ```markdown
   <!-- APPROVED by [Your Name], [date] -->
   ```
6. Tell Dev: "Spec is ready at docs/specs/..."

### Auditing Risk

1. Prompt: `"Act as @scope-audit. Audit the spec I just approved for risks and unsupported assumptions"`
2. Agent produces `scope-audit-report.md` with verdict: PASS / REVISE / ABANDON
3. Read it (3 min)
4. If PASS: tell Dev "Ready to proceed"
5. If REVISE: discuss with Dev, update spec

---

## For Dev: How to Use This

### Designing Architecture

1. Prompt: `"Act as @architect. From the approved spec at docs/specs/user-comments.md, design the system"`
2. Agent writes `docs/architecture/user-comments-design.md`
3. You read it (10 min)
4. Add approval marker if it's sound

### Implementing

1. Prompt: `"Act as @developer. Implement the approved tech-spec. Then use @self-check and @code-reviewer to verify"`
2. Agent writes code + tests
3. Agent runs @self-check (catches obvious issues)
4. Agent runs @code-reviewer (security, conventions)
5. You review the diff (15 min)
6. Commit if approved

### Testing Edge Cases

For risky changes (auth, payments, migrations):
1. Prompt: `"Act as @quality-check. Test these edge cases: [list]"`
2. Agent writes test cases, runs them
3. You verify results

---

## Common workflows (shortcuts)

**Standard feature:** `@spec-writer` → (PM approval) → `@scope-audit` (PASS) → `@architect` → (design approval) → `@developer` → `@self-check` → `@code-reviewer` → ship.

**Bug fix:** `@developer` → `@self-check` → `@code-reviewer` → ship.

**High-risk (auth, payments, migrations):** Same as standard feature, plus `@quality-check` before ship.

**Resume later or switch tools:** Use `@session-memory` and keep `memory.md`; otherwise infer progress from which artifacts exist under `docs/`.

---

## Troubleshooting

| Symptom | What to do |
|---|---|
| Agent asks many questions during spec work | Answer them; clearer scope avoids wrong builds. |
| You only want a quick code tweak | Skip to `@developer` + review skills for tiny changes; gates exist for larger work. |
| Lost chat after switching IDE | Lean on artifacts in repo (`docs/specs/`, `docs/architecture/`, `memory.md` if used). |

---

## Comparison: LAF vs. VPF

| Aspect | LAF (This Framework) | VPF (Virtual Product Factory) |
|---|---|---|
| **Skills** | 8 (lean teams only) | 32 (full org) |
| **Naming** | Plain English (@scope-audit) | Military jargon (@red-team) |
| **Target** | PM + Dev, no QA | Multi-tool teams, all roles |
| **Docs structure** | Industry standard (docs/) | Workflow-centric (root-level) |
| **Setup time** | 15 min | 30+ min |
| **Learning curve** | 1 hour | 4 hours |

**When to use LAF:** Small team, clear PM/Dev split, want simplicity.
**When to use VPF:** Large team, multiple roles, need all 32 skills.

---

## File Structure

```
lean-agent-framework/
├── README.md                       ← You are here
├── LICENSE (MIT)
├── package.json
├── setup.sh                         ← POSIX setup (Linux/macOS/Git Bash)
├── setup.ps1                        ← PowerShell setup (Windows)
├── .gitignore
│
├── AGENTS.md                       ← Universal rulebook (fork upstream, customize in your org)
├── CONVENTIONS.md                  ← Template for team customization
├── INDEX.md                        ← Skill index & workflows (human navigation)
│
│   ├── spec-writer/SKILL.md
│   ├── scope-audit/SKILL.md
│   ├── architect/SKILL.md
│   ├── developer/SKILL.md
│   ├── self-check/SKILL.md
│   ├── code-reviewer/SKILL.md
│   ├── quality-check/SKILL.md
│   └── session-memory/SKILL.md
│
├── templates/                      ← Artifact templates (gate workflow)
│   └── APPROVAL-WORKFLOW.md
│
├── examples/                       ← Reference examples
│   ├── sample-spec.md
│   └── sample-tech-spec.md
```

---

## Setup Options

### Option 1: Git Submodule (Recommended for teams)

```bash
git submodule add https://github.com/your-org/lean-agent-framework.git .laf
git submodule update --init --recursive
cp .laf/AGENTS.md .
cp .laf/CONVENTIONS.md .

# Linux/Mac - All tools (recommended):
bash .laf/setup.sh --tools cursor,claude,copilot,windsurf

# Windows PowerShell - All tools (recommended):
powershell -ExecutionPolicy Bypass -File .laf/setup.ps1 -tools "cursor,claude,copilot,windsurf"
```

### Option 2: Setup Specific Tools Only

```bash
# Linux/Mac - Individual tools:
bash .laf/setup.sh --tools cursor      # Just Cursor
bash .laf/setup.sh --tools claude      # Just Claude Code
bash .laf/setup.sh --tools copilot     # Just GitHub Copilot
bash .laf/setup.sh --tools windsurf    # Just Windsurf

# Windows PowerShell - Individual tools:
powershell -ExecutionPolicy Bypass -File .laf/setup.ps1 -tools "cursor"
powershell -ExecutionPolicy Bypass -File .laf/setup.ps1 -tools "claude"
powershell -ExecutionPolicy Bypass -File .laf/setup.ps1 -tools "copilot"
powershell -ExecutionPolicy Bypass -File .laf/setup.ps1 -tools "windsurf"
```

### Option 3: Manual Symlinks (No setup script)

If you prefer to create symlinks manually:

```bash
# Linux/Mac:
mkdir -p .cursor .github .kiro/steering
ln -sf ../AGENTS.md .cursor/rules.md
ln -sf AGENTS.md .cursorrules
ln -sf ../AGENTS.md .github/copilot-instructions.md
ln -sf AGENTS.md .windsurfrules
ln -sf AGENTS.md .claude.md
ln -sf ../../AGENTS.md .kiro/steering/agents.md

# Windows (PowerShell):
mkdir -p .cursor, .github, .kiro/steering
New-Item -ItemType SymbolicLink -Path ".cursor/rules.md" -Target "../AGENTS.md" -Force
New-Item -ItemType SymbolicLink -Path ".cursorrules" -Target "AGENTS.md" -Force
New-Item -ItemType SymbolicLink -Path ".github/copilot-instructions.md" -Target "../AGENTS.md" -Force
New-Item -ItemType SymbolicLink -Path ".windsurfrules" -Target "AGENTS.md" -Force
New-Item -ItemType SymbolicLink -Path ".claude.md" -Target "AGENTS.md" -Force
New-Item -ItemType SymbolicLink -Path ".kiro/steering/agents.md" -Target "../../AGENTS.md" -Force
```

**Windows users:** If symlinks fail due to permissions:

1. Enable Developer Mode: `Settings → Privacy & Security → For developers → Developer Mode (ON)`
2. Re-run the setup script, or
3. Manually copy `AGENTS.md` into each tool's config location instead of symlinking:
   ```powershell
   Copy-Item AGENTS.md .cursorrules
   Copy-Item AGENTS.md .claude.md
   Copy-Item AGENTS.md .github/copilot-instructions.md
   Copy-Item AGENTS.md .windsurfrules
   ```

**Note:** With copies, edits to `AGENTS.md` won't auto-propagate to all tools. Symlinks are recommended.

### Option 4: Direct Clone

```bash
git clone https://github.com/your-org/lean-agent-framework.git
cp lean-agent-framework/AGENTS.md your-project/
cp lean-agent-framework/CONVENTIONS.md your-project/
# Then run setup script (see Option 1 or 2) or create symlinks manually (see Option 3)
```

---

## Integration with AI Tools

The setup script creates symlinks so all AI tools read the same `AGENTS.md`:

```bash
.cursorrules → AGENTS.md
.github/copilot-instructions.md → AGENTS.md
.claude.md → AGENTS.md
.kiro/steering/agents.md → AGENTS.md
```

**Edit `AGENTS.md` once. All tools read the update.**

---

## Success Metrics

- ✅ PM can approve specs without Git knowledge
- ✅ Dev implements from spec + tech-spec with no context loss
- ✅ Async handoffs work (tool switches, time zones)
- ✅ One PR per feature (not 5)
- ✅ Artifacts persist in repo (searchable, versioned)
- ✅ New team members onboard in 1 hour
- ✅ Works with Cursor, Claude Code, Copilot, Windsurf

---

## Next Steps

1. **Fork this repo** or clone it into your project
2. **Customize `CONVENTIONS.md`** for your stack
3. **Run** `.laf/setup.sh` or `.laf/setup.ps1` from your project root (or create symlinks manually — see Setup Options above)
4. **Read [`AGENTS.md`](AGENTS.md)** (rules) and **[`INDEX.md`](INDEX.md)** (when to use which skill)
5. Skim **`skills/*/SKILL.md`** for roles you invoke often
6. **Create your first feature** using the workflow above

---

## Contributing

Found a bug? Have a clearer name for a skill? Want to add a new skill?

1. Open an issue
2. Propose the change
3. Submit a PR

All changes should:
- Maintain the "lean" philosophy (8 skills, not 32)
- Use clear, non-jargon names
- Document new concepts in **`README.md`** / **`INDEX.md`** as appropriate
- Include or update **`skills/<skill-name>/SKILL.md`** files and examples where relevant

### For Future Tool Support

If adding a new AI tool:
1. Determine its system prompt / config file location (check tool docs)
2. Add to the **Supported AI Tools** table in `README.md`
3. Create symlink or copy command in `setup.sh` / `setup.ps1`
4. Update `AGENTS.md` Rule 3 comment if tool has different config format

If a tool doesn't support Markdown:
- Use `INDEX.md` as a reference; manually translate key rules into that tool's format
- Consider submitting a PR with a **tool adapter** (e.g., `.md` → `.toml` or `.yaml` converter)

---

## License

MIT — Use freely, modify, fork, and share.

---

## Questions?

- **How do I customize this for my team?** → Edit `CONVENTIONS.md`
- **Which skill should I use next?** → **[INDEX.md](INDEX.md)** (Quick Reference section)
- **How do I add a new skill?** → Add **`skills/<name>/SKILL.md`**, extend **`INDEX.md`** and your copy of **`AGENTS.md`** if routing changes, update **`README.md`** skill table if needed
- **Can I use this with [tool]?** → Yes, if it reads markdown system prompts (Cursor, Claude Code, Copilot, Windsurf all do)
- **Is this production-ready?** → Yes. Start with 1 small feature to validate.

---

## Tested Compatibility

This framework has been verified with:

| Tool | Version | Config File | Status |
|------|---------|-------------|--------|
| **Cursor** | v0.43+ | `.cursorrules` | ✅ Active |
| **Claude Code** | 2026-05+ | `.claude.md` | ✅ Active |
| **GitHub Copilot** | 2026 Q2+ | `.github/copilot-instructions.md` | ✅ Supported |
| **Windsurf** | Latest | `.windsurfrules` | ✅ Supported |
| **Git** | 2.30+ | (symlink support) | ✅ Required |

**Windows note:** Symlink creation requires either admin privileges or Developer Mode enabled. See Setup Options → Option 3 for fallback.

---

## Inspiration & Attribution

Built on principles from:
- [Virtual Product Factory](https://github.com/vshrinath/virtual-product-factory) by Shrinath V
- Documentation-as-Code practices
- Architecture Decision Records (ADRs)
- Lean product development

---

**Built for teams that ship fast, together.**
