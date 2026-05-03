# Getting Started with Lean Agent Framework

## You're 15 Minutes Away From Using This

### Step 1: Copy Core Files to Your Project (5 min)

```bash
# If using this framework as a git submodule:
cd your-project/
git submodule add https://github.com/your-org/lean-agent-framework.git .laf

# Copy the rulebook and template:
cp .laf/AGENTS.md .
cp .laf/CONVENTIONS.md .

# Or if just cloning:
git clone https://github.com/your-org/lean-agent-framework.git
cp lean-agent-framework/AGENTS.md your-project/
cp lean-agent-framework/CONVENTIONS.md your-project/
```

### Step 2: Customize CONVENTIONS.md (5 min)

Edit `CONVENTIONS.md` in your project root:

```markdown
# Your Tech Stack
Language: TypeScript
Framework: Next.js
DB: PostgreSQL

# Your File Structure
src/
├── components/
├── pages/
├── services/
└── lib/

# Your Testing
Jest with 80% coverage target
```

Save and commit.

### Step 3: Set Up Tool Integration (5 min)

Create symlinks so all AI tools read the same AGENTS.md:

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

Commit the symlinks.

---

## Create Your First Feature (30 min)

### 1. PM: Scope the Feature

Use Cursor or Claude Code:

```
Prompt: "I need you to act as @spec-writer. Scope this feature: [your idea]"
```

The agent will:
- Ask clarifying questions
- Write `docs/specs/YYYY-MM-DD-feature-name.md`
- List acceptance criteria

You read it (5 min) and add approval marker:

```markdown
<!-- APPROVED by [Your Name], [date] -->
```

### 2. Dev: Audit Scope

```
Prompt: "Act as @scope-audit. Check the spec for risks."
```

The agent produces `scope-audit-report.md` with verdict: PASS / REVISE / ABANDON

You read it (3 min). If PASS, confirm:

```markdown
<!-- AUDIT-APPROVED by [Your Name], [date] -->
```

### 3. Dev: Design Architecture

```
Prompt: "Act as @architect. Design the system from the approved spec."
```

The agent writes `docs/architecture/[feature]-design.md` with components, data flow, tradeoffs.

You review (10 min) and add marker:

```markdown
<!-- ARCH-APPROVED by [Your Name], [date] -->
```

### 4. Dev: Implement

```
Prompt: "Act as @developer. Implement this. Then use @self-check and @code-reviewer to review."
```

The agent:
- Writes code + tests
- Runs @self-check (catches obvious issues)
- Runs @code-reviewer (security check)

You review code (15 min). If good:

```bash
git add src/ tests/ docs/
git commit -m "feat: [feature name]"
git push
```

### 5. Merge & Ship

```bash
git pull origin
# In GitHub/GitLab: Create PR, merge when both PM and Dev approve
```

---

## Reference Files

| File | Purpose | Where |
|---|---|---|
| `AGENTS.md` | Universal rules (read once) | Your project root |
| `CONVENTIONS.md` | Your team's stack/style (customize this) | Your project root |
| `INDEX.md` | Skill reference | This repo |
| `skills/spec-writer/SKILL.md` | When scoping features | This repo |
| `skills/scope-audit/SKILL.md` | When auditing risk | This repo |
| `skills/architect/SKILL.md` | When designing | This repo |
| `skills/developer/SKILL.md` | When building | This repo |
| `skills/self-check/SKILL.md` | When reviewing your own code | This repo |
| `skills/code-reviewer/SKILL.md` | When doing pre-merge review | This repo |
| `skills/quality-check/SKILL.md` | When testing risky changes | This repo |
| `skills/session-memory/SKILL.md` | When resuming multi-day work | This repo |

---

## Common Workflows

### Workflow A: Simple Feature (4–6 hours)

```
@spec-writer → (PM approves) → @scope-audit (PASS) → @architect → @developer → @self-check → @code-reviewer → Ship
```

**Use this for:** New UI, new endpoint, data reporting

### Workflow B: Bug Fix (15–60 min)

```
@developer → @self-check → @code-reviewer → Ship
```

**Use this for:** Critical issues, regressions

### Workflow C: High-Risk Feature (1–2 days)

```
@spec-writer → @scope-audit → @architect → @developer → @self-check → @code-reviewer → @quality-check → Ship
```

**Use this for:** Auth, payments, database migrations

### Workflow D: Resume After Context Switch

```
@session-memory (read memory.md, understand state) → Continue from next step
```

**Use this for:** Multi-day work, tool switches

---

## Key Concepts

### Artifacts = State

Every handoff creates a file that encodes where you are:

- `docs/specs/` = Scoping phase
- `scope-audit-report.md` = Audit phase
- `docs/architecture/` = Design phase
- Code + tests = Implementation phase
- `review-report.md` = Review phase

To resume: check which files exist, start from the next missing one.

### Approval Markers = Gates

No proceeding without explicit approval:

```markdown
<!-- APPROVED by [Name], [date] -->
```

If this marker is missing, the agent stops and asks for it.

### One Skill at a Time

The agent loads only:
1. `AGENTS.md` at session start
2. One skill file when adopting that role
3. Unloads the skill after handoff

This keeps context lean.

---

## Troubleshooting

### "The agent is doing too much / asking too many questions"

**Solution:** You're in a skill that needs clarification. Answer the questions. Better to clarify now than build wrong.

### "I just want to code, why all the specs?"

**Solution:** For small fixes, skip to @developer directly. Specs are for features taking 1+ days. For 30-min fixes, just code.

### "The agent rejected my code / asked me to revise"

**Solution:** That's working as intended. The gates prevent bugs. Fix the issue and re-check.

### "I switched tools and the context is lost"

**Solution:** Use @session-memory. It persists decisions and state so you can resume in any tool.

### "Where do I put the artifacts?"

**Solution:** See ARTIFACT LOCATIONS in README.md. Specs in `docs/specs/`, designs in `docs/architecture/`, reviews in root level or `docs/`.

---

## Next Steps

1. **Read the README.md** (10 min) — full overview
2. **Read AGENTS.md** (15 min) — understand the 16 rules
3. **Skim each SKILL.md** (5 min each) — know they exist, what they do
4. **Try Workflow A on a small feature** (4 hours) — see it in action
5. **Adjust CONVENTIONS.md as needed** — make it fit your team

---

## Questions?

- **"How do I...?"** → Check README.md or INDEX.md
- **"What does this skill do?"** → Read the SKILL.md file
- **"What should I do next?"** → Check the "Handoff" section in the current skill
- **"How do I customize this?"** → Edit CONVENTIONS.md
- **"I'm stuck"** → Open an issue or ask the team

---

## Success Checklist

After setting up, you should be able to:

- [ ] Run `AGENTS.md` and `CONVENTIONS.md` in your AI tool (symlinks work)
- [ ] List the 8 skills and what they do (from INDEX.md)
- [ ] Know which skill to use for your current task
- [ ] Understand what "approval marker" means
- [ ] Know where artifacts are stored (`docs/specs/`, `docs/architecture/`, etc.)
- [ ] Know what "done" means (all gates passed)

If you can check all boxes, you're ready. Ship your first feature!

---

**Built for teams that ship fast, together.**
