# Layer 6: Test Suite Template

**Purpose:** Define what "correct" behavior looks like so agents (and humans) know when code is done.

---

## Layer 6 Decision Checklist

**Do you have a test strategy?**

- [ ] No — Fill out this template to establish standards
- [ ] Yes — Document what you're doing so agents follow the pattern

---

## Your Test Requirements

Fill this out once per project, commit to `.project/test-requirements.md`.

### 1. Coverage & Scope

```markdown
## Test Coverage Targets

### Overall Coverage
- Minimum: 80% (branches, not just lines)
- Target: 85%+ (stretch goal)
- Low coverage OK for: Configuration files, generated code, throwaway scripts
- 100% coverage required for: Authentication, payments, data deletion, migration code

### Coverage Breakdown

#### Unit Tests (60% of total coverage)
- **What:** Individual functions in isolation
- **Examples:**
  - validateEmail('invalid') returns false
  - formatDate(new Date(...)) returns expected string
  - hashPassword('abc') returns non-deterministic hash
- **Coverage target:** 80% of src/utils/, src/services/
- **Run time:** <1s

#### Integration Tests (25% of total coverage)
- **What:** Test layer boundaries (API + database, service + API, service + external API)
- **Examples:**
  - POST /users with valid data returns 201 and creates user in database
  - userService.updateUser() calls database.update() correctly
  - userService.sendEmail() calls email API with right parameters
- **Coverage target:** 70% of src/api/, src/services/
- **Run time:** 5-10s

#### E2E Tests (15% of total coverage)
- **What:** Full user workflows end-to-end
- **Examples:**
  - User signs up → verifies email → logs in → sees profile
  - Admin creates org → invites user → user accepts → views org dashboard
- **Scope:** Top 3-5 critical flows only (not every feature)
- **Run time:** 30-60s
- **Note:** E2E tests are slow and maintenance-heavy. Use sparingly.

### Coverage Report
- Tool: [e.g., Jest, Pytest, Coverage.py]
- Threshold: [80%]
- Failure policy: Merge blocked if coverage drops below threshold
```

---

### 2. Test Location & Structure

```markdown
## Test File Organization

### Colocated Unit Tests
```
src/
├── utils/
│   ├── validate-email.ts
│   ├── validate-email.test.ts        ← Adjacent to source
│   ├── format-date.ts
│   └── format-date.test.ts           ← Adjacent to source
│
├── services/
│   ├── user-service.ts
│   └── user-service.test.ts          ← Adjacent to source
```

Benefits:
- Easy to find tests for a given file
- Tests move with the code during refactors
- Clear 1:1 relationship between code and tests

### Centralized Integration & E2E Tests
```
tests/
├── integration/
│   ├── user-routes.test.ts           ← API + database integration
│   ├── payment-flows.test.ts         ← Service + external API integration
│   └── auth-middleware.test.ts       ← Middleware testing
│
├── e2e/
│   ├── signup-flow.test.ts           ← Full user journey
│   ├── payment-flow.test.ts          ← Full payment journey
│   └── admin-setup-flow.test.ts
│
└── fixtures/
    ├── user-fixtures.ts              ← Reusable test data
    ├── transaction-fixtures.ts
    └── test-database-setup.ts        ← Database seeding for tests
```

### Naming
- Test files: [source].test.ts or [source].spec.ts
- Test functions: describe('[feature]', () => { it('should [expected behavior]', () => { ... }) })
- Clear, readable names:
  - ✅ it('should reject login with invalid password')
  - ✅ it('should create user with valid email and password')
  - ❌ it('test login')
  - ❌ it('error handling')
```

---

### 3. High-Risk Areas (100% Coverage Required)

```markdown
## Code That Must Have 100% Test Coverage

These areas have high blast radius if broken. Test every branch.

### Authentication & Authorization
- Login/logout flows
- Permission checks
- Token validation
- Session management

### Payment Processing
- Payment initiation
- Payment confirmation
- Refund handling
- Fraud detection

### Data Deletion & Migrations
- User account deletion (cascading deletes)
- Data migration scripts
- Data export/import

### Critical Business Logic
- Financial calculations (pricing, discounts)
- Email sending (critical alerts)
- Notification delivery
- Inventory management

### Security Filters
- Input validation
- Output encoding (XSS prevention)
- SQL injection prevention
- CSRF token handling

**To verify coverage:**
```
npm run test:coverage -- --path src/auth
npm run test:coverage -- --path src/payments
```

If coverage < 100%, merge is blocked.
```

---

### 4. Pre-Commit & CI Gates

```markdown
## Automated Testing Gates

### Pre-Commit Hook (Local)
```bash
# Before every commit, run:
npm run test:unit

# If tests fail, commit is blocked
# Developer must fix tests or force-push (not recommended)
```

Benefits:
- Catches bugs before they're pushed
- Faster feedback loop than waiting for CI
- Slows down commits slightly (trade-off: early feedback)

**Setup:**
```json
{
  "husky": {
    "hooks": {
      "pre-commit": "npm run test:unit && npm run lint"
    }
  }
}
```

### CI Gate (GitHub/GitLab Actions)
```yaml
name: Tests

on: [pull_request, push]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install dependencies
        run: npm install
      - name: Run unit tests
        run: npm run test:unit
      - name: Run integration tests
        run: npm run test:integration
      - name: Check coverage
        run: npm run test:coverage
        # Fails if coverage < 80%

  # Merge blocked if any job fails
```

**Rules:**
- All tests must pass before merge
- Coverage must be ≥ 80% (or your target)
- No exceptions, no force-merge
- Failing tests = broken branch = fix or close PR

### Test Commands
```bash
# Run all tests
npm run test

# Run unit tests only (fast)
npm run test:unit

# Run integration tests
npm run test:integration

# Run E2E tests (slow)
npm run test:e2e

# Check coverage
npm run test:coverage

# Watch mode (re-run on changes)
npm run test:watch

# Run specific test file
npm run test -- user-service.test.ts
```
```

---

### 5. Test Data Strategy

```markdown
## Test Fixtures & Factories

### Fixtures (Static Test Data)
```typescript
// tests/fixtures/user-fixtures.ts
export const VALID_USER = {
  id: 'user-1',
  email: 'test@example.com',
  password: 'hashed-password',
  createdAt: new Date('2026-05-01'),
};

export const INVALID_USER = {
  email: '', // Missing email
  password: '',
};

// Usage in tests:
it('should accept valid user', () => {
  const result = createUser(VALID_USER);
  expect(result.id).toBeDefined();
});
```

### Factories (Dynamic Test Data)
```typescript
// tests/factories/user-factory.ts
export function createUserFactory(overrides = {}) {
  return {
    id: 'user-' + Math.random(),
    email: 'test-' + Math.random() + '@example.com',
    password: 'hashed-password',
    ...overrides,
  };
}

// Usage:
it('should handle multiple users', () => {
  const user1 = createUserFactory();
  const user2 = createUserFactory({ email: 'other@example.com' });
  expect(user1.id).not.toBe(user2.id);
});
```

### Database Seeding for Integration Tests
```typescript
// tests/test-database-setup.ts
export async function seedTestDatabase() {
  await db.query('TRUNCATE users, orders, transactions');
  await db.query('INSERT INTO users VALUES ...', [VALID_USER]);
  // Seed data for all integration tests
}

// In test setup:
beforeAll(async () => {
  await seedTestDatabase();
});

afterEach(async () => {
  await db.query('TRUNCATE users, orders, transactions');
});
```

### Guidelines
- Use fixtures for static data (same in every test)
- Use factories for varying data (random IDs, emails)
- Seed database before integration tests
- Clean up after tests (truncate tables, delete files)
```

---

### 6. Common Test Patterns

```markdown
## Example Unit Test
```typescript
import { validateEmail } from './validate-email';

describe('validateEmail', () => {
  it('should accept valid email', () => {
    expect(validateEmail('test@example.com')).toBe(true);
  });

  it('should reject email without @', () => {
    expect(validateEmail('testexample.com')).toBe(false);
  });

  it('should reject email without domain', () => {
    expect(validateEmail('test@')).toBe(false);
  });

  it('should handle special characters', () => {
    expect(validateEmail('test+tag@example.co.uk')).toBe(true);
  });
});
```

## Example Integration Test
```typescript
import { userService } from './user-service';
import { db } from './database';

describe('userService.createUser', () => {
  beforeEach(async () => {
    await db.query('TRUNCATE users');
  });

  it('should create user in database', async () => {
    const user = await userService.createUser({
      email: 'test@example.com',
      password: 'password123',
    });

    expect(user.id).toBeDefined();
    expect(user.email).toBe('test@example.com');

    // Verify it's actually in the database
    const found = await db.query('SELECT * FROM users WHERE id = ?', user.id);
    expect(found).toBeDefined();
  });

  it('should reject duplicate email', async () => {
    await userService.createUser({ email: 'test@example.com', password: 'pass' });
    
    await expect(
      userService.createUser({ email: 'test@example.com', password: 'pass' })
    ).rejects.toThrow('Email already in use');
  });
});
```

## Example E2E Test
```typescript
import { request } from './test-client';

describe('Signup Flow', () => {
  it('should allow user to sign up and log in', async () => {
    // Step 1: Sign up
    const signupRes = await request.post('/signup').send({
      email: 'new@example.com',
      password: 'password123',
    });
    expect(signupRes.status).toBe(201);
    const userId = signupRes.body.id;

    // Step 2: Verify email (simulate email link)
    await db.query('UPDATE users SET verified = true WHERE id = ?', userId);

    // Step 3: Log in
    const loginRes = await request.post('/login').send({
      email: 'new@example.com',
      password: 'password123',
    });
    expect(loginRes.status).toBe(200);
    expect(loginRes.body.token).toBeDefined();

    // Step 4: Access protected endpoint
    const profileRes = await request
      .get('/profile')
      .set('Authorization', 'Bearer ' + loginRes.body.token);
    expect(profileRes.status).toBe(200);
    expect(profileRes.body.email).toBe('new@example.com');
  });
});
```
```

---

### 7. High-Risk Areas: Extra Test Cases

```markdown
## Authentication: Always Test These Cases

```typescript
describe('Authentication', () => {
  it('should allow login with correct password', () => { ... });
  it('should reject login with wrong password', () => { ... });
  it('should reject login with non-existent email', () => { ... });
  it('should reject login if account is disabled', () => { ... });
  it('should reject expired tokens', () => { ... });
  it('should refresh expired tokens', () => { ... });
  it('should logout and invalidate token', () => { ... });
});
```

## Payments: Always Test These Cases

```typescript
describe('Payment Processing', () => {
  it('should charge card with valid details', () => { ... });
  it('should reject payment with insufficient funds', () => { ... });
  it('should handle network error during charge', () => { ... });
  it('should not double-charge on retry', () => { ... });
  it('should refund successfully', () => { ... });
  it('should reject refund for non-existent payment', () => { ... });
  it('should handle concurrent payments from same user', () => { ... });
});
```

## Data Deletion: Always Test These Cases

```typescript
describe('User Deletion', () => {
  it('should delete user and cascade to related data', () => { ... });
  it('should mark orders as orphaned if cascade fails', () => { ... });
  it('should not delete if deletion is within grace period', () => { ... });
  it('should send deletion confirmation email', () => { ... });
  it('should be non-reversible after 30 days', () => { ... });
});
```
```

---

## Your Project's Test Strategy

**Copy & customize:**

```markdown
## Our Test Requirements (Project-Specific)

### Coverage
- Unit: 80%
- Integration: 70%
- Total: 80%
- High-risk areas: 100%

### Test Location
- Unit tests: Adjacent to source ([file].test.ts)
- Integration: tests/integration/
- E2E: tests/e2e/
- Fixtures: tests/fixtures/

### Pre-Commit
- Run: npm run test:unit
- Blocked if: Any test fails

### CI/CD
- Run: npm test (all tests)
- Blocked if: Coverage < 80% OR any test fails

### High-Risk 100% Coverage
- src/auth/**
- src/payments/**
- src/db/migrations/

### Test Commands
- npm run test           → Run all tests
- npm run test:unit     → Unit tests only (fast)
- npm run test:coverage → Check coverage
- npm run test:watch   → Watch mode
```

---

## Monitoring Test Health

**Every sprint, check:**

1. **Coverage hasn't dropped:** Run `npm run test:coverage`
2. **High-risk areas are 100%:** Check auth, payments, deletions
3. **Tests run fast:** Unit tests should complete in <2s
4. **No flaky tests:** If a test sometimes fails, fix it
5. **Test names are clear:** Can you understand what's being tested without reading the code?

---

## Common Mistakes

❌ **Writing only happy-path tests** — You need error cases too
✅ **Test happy path + 2-3 error cases** — Covers 80% of bugs

❌ **Using generic test names like "test login"** — Unclear what's being tested
✅ **Specific names: "should reject login with wrong password"** — Easy to understand

❌ **Skipping E2E tests entirely** — You have no verification of user workflows
✅ **Focus on top 3-5 critical flows** — E2E is slow but worth it for critical paths

❌ **No pre-commit hook** — Merge broken code by accident
✅ **Pre-commit runs tests** — Catch bugs before they're pushed

❌ **Ignoring coverage reports** — Coverage gradually decreases
✅ **Monitor coverage quarterly** — Keep it above threshold

---

## Next Steps

1. Copy this template to `.project/test-requirements.md`
2. Customize coverage targets for your project
3. Set up pre-commit hooks (npm run test:unit)
4. Set up CI/CD gate (GitHub Actions or equivalent)
5. Implement high-risk area test templates
6. Share with team and review quarterly
