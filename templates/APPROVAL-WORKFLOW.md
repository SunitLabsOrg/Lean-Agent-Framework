# Approval Workflow Guide

## How Approvals Work

Every feature handoff requires an explicit approval marker in the artifact files. This ensures:

1. Nothing happens without someone saying "yes"
2. Decisions are recorded in Git (for audit trail)
3. Work can resume cleanly after context switches

---

## The Approval Process

### 1. Spec Phase (PM Approves)

**What happens:**
- @spec-writer creates `docs/specs/YYYY-MM-DD-feature-name.md`
- PM reads the spec (5 min)
- PM adds approval marker to the file

**Approval marker:**
```markdown
<!-- APPROVED by [PM Name], [date] [time] -->
```

**Next step:** Tell Dev "Spec approved. Ready for @scope-audit."

---

### 2. Audit Phase (PM Confirms Audit Result)

**What happens:**
- @scope-audit creates `scope-audit-report.md`
- Report contains verdict: PASS / REVISE / ABANDON
- PM reads audit (3 min)
- PM confirms verdict is acceptable

**If PASS:**
```markdown
<!-- AUDIT-APPROVED by [PM Name], [date] [time] -->
```

**If REVISE:**
PM updates spec and re-runs @scope-audit.

**Next step:** Tell Dev "Audit passed. Ready for @architect."

---

### 3. Architecture Phase (Dev Approves)

**What happens:**
- @architect creates `docs/architecture/[feature]-design.md`
- Dev reads design (10 min)
- Dev checks: does this match our stack? Is it reasonable?
- Dev adds approval marker

**Approval marker:**
```markdown
<!-- ARCH-APPROVED by [Dev Name], [date] [time] -->
```

**Next step:** "Design approved. Ready for @developer."

---

### 4. Code Phase (Dev Reviews)

**What happens:**
- @developer writes code + tests
- @self-check runs (catches obvious issues)
- @code-reviewer reviews (security, conventions)
- Dev reads review (10 min)
- If PASS: Dev marks ready for merge

**Approval marker (in PR description or a file):**
```markdown
<!-- CODE-APPROVED by [Dev Name], [date] [time] -->
```

**Next step:** Merge PR, deploy, ship.

---

## Tracking Approvals

### In Artifact Files (Simple)

Add HTML comments to the markdown files as approvals happen.

```markdown
# Feature: User Comments

[content]

<!-- APPROVED by PM Sunit, 2026-05-03 10:15 AM -->
```

### In .project/approvals.md (Detailed)

Keep a central approval log:

```markdown
## Feature: User Comments

### Spec Phase
- Status: APPROVED ✅
- Approved by: PM Sunit
- Date: 2026-05-03
- Time: 10:15 AM
- Notes: "Looks good. Out of scope: notifications."

### Audit Phase
- Status: PASS ✅
- Approved by: PM Sunit
- Date: 2026-05-03
- Time: 10:45 AM
- Notes: "No blockers."

### Architecture Phase
- Status: APPROVED ✅
- Approved by: Dev Lead
- Date: 2026-05-03
- Time: 11:30 AM
- Notes: "Uses existing PostgreSQL. Good."

### Code Phase
- Status: REVIEWED ✅
- Reviewed by: Dev Lead
- Date: 2026-05-03
- Time: 2:00 PM
- Notes: "Tests pass. Conventions met. Ready to merge."

### Shipped
- Date: 2026-05-03
- Time: 3:30 PM
- Deployed to: production
```

---

## Rules

1. **Never skip approval markers.** If an approval marker is missing, halt and ask for it.
2. **Each artifact must be approved before handoff.** A missing approval = not ready.
3. **Markers are human-written.** The agent checks for them, but humans write them.
4. **Approval = understanding + confidence.** Don't approve something you don't understand.
5. **Reviewers can say "revise".** It's better to say no now than ship a broken feature.

---

## Common Questions

**Q: What if I'm in a hurry?**  
A: Skipping approval gates is how technical debt gets created. Don't. The gates exist for a reason.

**Q: Can I approve my own code?**  
A: For small projects, maybe. For security/payment/auth code, always get someone else to review.

**Q: What if Dev disagrees with the spec?**  
A: That's what the audit is for. If concerns surface during architecture, say so and revise the spec. Better now than after building.

**Q: How long does approval take?**  
A: 5-15 minutes per gate, depending on complexity. Total overhead: ~45 min per feature. Worth it to prevent rework.
