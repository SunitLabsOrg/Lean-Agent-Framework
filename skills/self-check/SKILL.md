---
name: self-check
description: Pre-handoff quality check. Forces the agent to critique its own code before declaring done.
category: quality
handoff-from:
  - developer
handoff-to:
  - code-reviewer
version: 1.0.0
---

# @self-check — Pre-Handoff Self Review

**Philosophy:** Catch the obvious issues before human review. Saves time.

## When to invoke

- Code is written and tests pass locally
- Dev wants a quick review before handing off to @code-reviewer
- Pre-merge sanity check

## Responsibilities

- Review the diff (what changed)
- Catch obvious issues: logic errors, missing tests, style violations
- Identify potential problems before @code-reviewer sees them
- Produce an annotated diff (inline comments)
- Do NOT fix issues — just flag them; @developer fixes them

## Self-Check Process

### Step 1: Review the Diff

Look at: `git diff` or the code diff provided

For each change, ask:

1. **Logic:** Does this actually implement the design?
2. **Tests:** Is there a test for this code? Does it test the error case?
3. **Style:** Does it match the project's conventions?
4. **Security:** Any obvious security issues? (SQL injection, XSS, auth bypass)
5. **Performance:** Any obvious N+1 queries or inefficiencies?
6. **Error handling:** What happens if this fails? Is the error message clear?
7. **Side effects:** Does this change behavior elsewhere unintentionally?

### Step 2: Annotate Issues Inline

Use inline comments like:

```
LINE 42: Logic Error
  for (let i = 0; i < comments.length; i++) {
    const comment = comments[i];
    console.log(comment); // ← This should be logging comment.id, not the whole object
  }

  Fix: console.log(`Comment ${comment.id} created`);
```

Or for missing tests:

```
LINE 89: Missing Test Coverage
  function validateEmail(email) {
    return email.includes('@');
  }

  Missing test cases: empty string, email without @, email with multiple @, long email
  Add to tests/validateEmail.test.js

  Suggested test:
  it('should reject email without @', () => {
    expect(validateEmail('noemail')).toBeFalsy();
  });
```

### Step 3: Categorize Issues

Group findings by severity:

**🔴 Blocker** (must fix before merge)
- Logic error (code doesn't do what it should)
- Security vulnerability
- Broken test
- Violates CONVENTIONS.md

**🟡 Warning** (should fix)
- Confusing code (needs a comment)
- Missing edge case test
- Performance concern
- Unused variable

**🟢 Nice to have** (can fix later)
- Code style optimization
- Refactoring opportunity
- Documentation improvement

### Step 4: Produce Report

Output format (inline annotated diff, or a summary file):

```markdown
# Self-Check Review

**Diff reviewed:** git diff HEAD~1
**Date:** YYYY-MM-DD
**Status:** Issues found, ready for developer to fix

## Blockers (must fix)
- [ ] Line 42: Logic error — loop variable used incorrectly
- [ ] Line 89: Missing error case test — validateEmail with empty string
- [ ] Line 150: SQL injection risk — query string not parameterized

## Warnings (should fix)
- [ ] Line 25: Unused variable `oldComments` — remove or use
- [ ] Line 88: Function too long (50 lines) — consider extracting logic

## Approved
- ✅ Tests pass locally
- ✅ Code compiles without warnings
- ✅ Follows project conventions
- ✅ No console errors in manual testing

## Next: Fix blockers and warnings, then re-check
```

### Step 5: Confirm Ready

When complete, confirm: "Self-check complete. [N] blockers, [M] warnings. Ready for @developer to fix, then @code-reviewer to review."

## Self-Check Principles

- Be critical but constructive
- Point out "why" something is wrong, not just "it's wrong"
- Suggest fixes when obvious
- Don't nitpick code style if the project's linter passes
- Flag patterns that might cause bugs later

## Common Issues to Catch

- Logic: Loop conditions, off-by-one, null checks, === vs ==
- Tests: Edge cases, error paths, async handling, mock cleanup
- Security: Input validation, SQL injection, XSS, auth checks
- Performance: N+1 queries, missing indexes, unnecessary loops
- Errors: Silent failures, swallowed exceptions, unclear messages
- Side effects: Global state changes, unintended mutations

## Handoff

**Next skill:** @code-reviewer (after blockers are fixed)

**What Dev should do:**
1. Read the self-check report
2. Fix all blockers
3. Fix warnings (or justify why they're okay)
4. Run tests again to verify fixes
5. Then request @code-reviewer

## Artifact

**Output:** Inline annotated diff, or `self-check-report.md`

This is not a blocker; it's a helper. The human Dev always has final say.

## Anti-patterns (do not do)

- Don't fix issues yourself — point them out, don't implement
- Don't be harsh or sarcastic
- Don't approve code that violates CONVENTIONS.md
- Don't miss obvious bugs to save time
