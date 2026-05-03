# PR Comments vs. Markdown Reports: Understanding the Difference

**Quick Answer:** They're NOT duplicates. PR comments provide real-time feedback during development; markdown reports provide formal approval records that persist in Git.

---

## When to Use Each

### PR Comments (GitHub/GitLab)

**Purpose:** Line-by-line, real-time feedback during code review

**Characteristics:**
- Tied to specific lines of code
- Dialogue-based (reviewer + developer can discuss)
- Visible immediately
- Resolved interactively
- Lives in PR history (archived, but not in repo)

**Examples:**

```
Line 10: src/MyApi/Features/Surveys/CreateSurveyCommand.cs

@code-reviewer:
"🚨 Security concern

Don't use bcrypt directly.
Use injected PasswordHasher service.

Why: Testable, mockable, swappable

❌ Current:
var hash = await bcrypt.Hash(pwd);

✅ Better:
var hash = await _passwordHasher.HashAsync(pwd);"

@developer (reply):
"Got it - fixing now"

@code-reviewer:
"Thanks, approved once fixed"
```

**When to use:**
- Point out specific issues
- Clarify implementation details
- Ask "why did you do this?"
- Negotiate on approach
- Back-and-forth discussion

---

### Markdown Reports (.project/review-report.md)

**Purpose:** Formal summary approval record that persists in Git

**Characteristics:**
- Summary-level (not line-specific)
- One-way record (not dialogue)
- Permanent (stored in Git)
- Archivable (can be referenced later)
- Compliance-friendly

**Example:**

```markdown
# Code Review Report

## Feature: Survey Creation
## Reviewer: @code-reviewer
## Date: 2026-05-03 4:30 PM
## Verdict: APPROVED

### Security Check
✅ PASSED
- Authorization gate present
- Input validation implemented
- SQL queries parameterized
- No hardcoded secrets
- One concern resolved: bcrypt injection (see PR #42 line 10)

### Convention Check
✅ PASSED
- Naming follows .NET standards
- File structure matches Features pattern
- Using dependency injection throughout

### Boundary Check
✅ PASSED
- API layer doesn't query database directly
- Business logic in service, not endpoint
- Clean separation of concerns

### Verdict
APPROVED - Ready for quality-check phase

All required checks passed.
One security concern was identified and resolved by developer.

Approved by: @code-reviewer
Timestamp: 2026-05-03 4:30 PM
```

**When to use:**
- Create formal approval record
- Archive for compliance/audit
- Handoff to next phase
- Reference later ("what did we decide?")
- Merge approval gates

---

## How They Work Together

### Timeline: Feature Development

```
Day 1, 2:00 PM
  Developer pushes code → PR #42 created
  
Day 1, 2:15 PM
  @code-reviewer reviews → Adds 5 inline PR comments
  └─ Comment on line 10: "Use injected PasswordHasher"
  └─ Comment on line 25: "Good: Dependency injection ✅"
  └─ Comment on line 42: "Naming inconsistent (minor)"
  └─ Comment on line 50: "Security check passed ✅"
  └─ Comment on line 100: "Nice: Clean boundaries ✅"

Day 1, 3:00 PM
  Developer responds & fixes issues
  Commits: abc123def456
  
Day 1, 3:15 PM
  @code-reviewer re-reviews → All comments resolved
  Posts final comment: "Looks good, ready to merge"

Day 1, 4:00 PM
  BEFORE MERGE: Create review-report.md
  Summarizes: "5 comments reviewed, all resolved, APPROVED"
  
Day 1, 4:15 PM
  Merge to main
  review-report.md is now part of Git history
```

---

## Key Differences (Side-by-Side)

| Aspect | PR Comments | Markdown Report |
|--------|---|---|
| **Scope** | Line-by-line | Summary-level |
| **Storage** | GitHub/GitLab servers | Git repository |
| **Persistence** | PR archived (not in repo) | Git history (permanent) |
| **Real-time** | ✅ Immediate | ❌ Manual update |
| **Dialogue** | ✅ Thread-based | ❌ One-way record |
| **Formal Record** | ⚠️ Partial | ✅ Complete |
| **Compliance** | ⚠️ Not in repo | ✅ Audit trail |
| **Search** | GitHub search | Git grep |
| **Purpose** | "Let's fix this" | "Here's the verdict" |

---

## Decision: Which Should You Use?

### For Solo Developers
**Use:** PR comments only (simpler, faster)

Markdown reports add overhead with no compliance benefit.

### For Small Teams (2-3 devs)
**Use:** Both (lightweight setup)

PR comments for dialogue, markdown for handoff.

### For Growing Teams (4+ devs)
**Use:** Both (formalize approval)

PR comments for development, markdown for records.

### For Compliance/Regulated Teams
**Use:** Both + archive

PR comments + markdown + move completed reports to `review-archive/`.

---

## How to Implement (Minimal)

### Option 1: Manual (No Automation)

**Step 1:** Have PR review discussion via comments

```
Developer pushes code → Reviewer adds PR comments
→ Developer responds & fixes
→ Reviewer approves comment
```

**Step 2:** Create markdown after approval

```markdown
# review-report.md

## Feature: Survey Creation
## Verdict: APPROVED
## Comments: See PR #42
```

That's it. Lightweight, manual, works well for small teams.

### Option 2: Automated (GitHub Actions)

Workflows can auto-post PR comments for:
- Scope audit (validate spec sections)
- Code review (check conventions, security)
- Quality checks (test results, coverage)

Then someone creates review-report.md as final record.

---

## Common Patterns

### Pattern 1: Comments for Feedback, Markdown for Archive

```
Development:
  PR Comments (back-and-forth)
        ↓
  All issues resolved
        ↓
Approval:
  Create review-report.md (summary)
        ↓
  Merge to main
```

### Pattern 2: Comments-Only (Minimal)

```
Development:
  PR Comments (discussion)
        ↓
Approval:
  GitHub "Approve" button
        ↓
  Merge (no markdown needed)
```

Use when: Solo dev or very small team, no compliance requirements.

### Pattern 3: Markdown-Only (Formal)

```
Development:
  Review without PR comments (or minimal)
        ↓
Approval:
  Create review-report.md
        ↓
  Merge after markdown approval
```

Use when: Compliance-heavy, formal approval required.

---

## FAQ

**Q: Aren't PR comments and review-report.md duplicates?**

A: No. PR comments are dialogue (development). Markdown is record (archive). Different purposes, both useful.

**Q: Do I need both?**

A: No. Use what fits your team:
- Solo/small → Comments only
- Growing → Both
- Formal/compliance → Both + archive

**Q: Which is the "source of truth"?**

A: PR comments are development truth. Markdown is approval truth. They serve different questions:
- PR comments answer: "How did we get here?"
- Markdown answers: "What did we decide?"

**Q: Can I automate PR comments?**

A: Yes, via GitHub Actions. Automate repetitive checks (naming, security, coverage).

**Q: Can I automate markdown reports?**

A: Partially. You can auto-template and populate with data, but the verdict (APPROVED/REVISE) is usually manual.

**Q: What if I forget to create review-report.md?**

A: No problem. PR comments are still there in GitHub. You can create markdown later as reference.

---

## Next Steps

1. **Start with PR comments** — Natural for GitHub/GitLab users
2. **Add markdown reports** — If you need formal records or multi-phase handoffs
3. **Automate repetitive checks** — Use GitHub Actions to post common findings
4. **Archive completed reports** — Move to `review-archive/` when feature ships

---

**Key Principle:** Use PR comments for development. Use markdown reports for approval and handoff. Let them work together, not compete.
