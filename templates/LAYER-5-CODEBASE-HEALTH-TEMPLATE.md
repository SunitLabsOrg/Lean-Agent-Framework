# Layer 5: Codebase Health Template

**Purpose:** Define how your code is organized, named, and documented so agents (and humans) understand it immediately.

---

## Layer 5 Decision Checklist

**Does your codebase have clear structure and naming?**

- [ ] No — Fill out this template to establish standards
- [ ] Yes — Document what you're already doing so agents follow the pattern

---

## Your Codebase Health Standards

Fill this out once per project, commit to `docs/codebase-health.md` or `.project/codebase-health.md`.

### 1. Naming Conventions

#### Functions & Methods

```markdown
## Naming: Functions & Methods

**Pattern:** [verb][noun] describing what it does, not how

Examples:
- ✅ getUserByEmail(email) — describes what is returned
- ✅ validateUserInput(input) — describes what is checked
- ✅ formatDate(date, format) — describes transformation
- ❌ fn(), doIt(), process() — too vague
- ❌ u(), getU() — too abbreviated

Convention:
- Async functions: prefix with async or suffix with Async
  - ✅ async fetchUserFromAPI(userId)
  - ✅ getUserAsync(userId)
- Private methods: prefix with _ or use language-specific private keyword
  - ✅ _validateEmail(email)
  - ✅ private validateEmail(email)
```

#### Files & Modules

```markdown
## Naming: Files & Modules

**Pattern:** lowercase, kebab-case, noun describing what's inside

Examples:
- ✅ user-service.ts — exports UserService class
- ✅ validate-email.ts — exports validateEmail function
- ✅ api-client.ts — exports API client utilities
- ❌ UserService.ts — PascalCase file (hard to find in ls)
- ❌ utils.ts — too generic, what utils?

Convention:
- One file per exported class or major function
- Related utilities: group in subdirectories (not in misc/ or utils/)
  - ✅ src/utils/date/format-date.ts
  - ✅ src/utils/date/parse-date.ts
  - ❌ src/utils/misc-helpers.ts
```

#### Directories

```markdown
## Naming: Directories

**Pattern:** lowercase, plural, describing category of contents

Examples:
- ✅ src/services/ — multiple service files
- ✅ src/utils/ — multiple utility modules
- ✅ src/types/ — multiple TypeScript types
- ✅ tests/ — test files
- ❌ src/Helpers/ — PascalCase, singular, vague
- ❌ src/service/ — singular (convention is plural)

```

---

### 2. File Organization

#### Source Code Structure (Customize for Your Stack)

```markdown
## File Organization

project-root/
├── src/
│   ├── api/                       ← HTTP layer (routing, status codes only)
│   │   ├── routes.ts              ← Express routes or equivalent
│   │   ├── middleware/            ← Auth, logging, error handling
│   │   │   ├── auth-middleware.ts
│   │   │   └── error-handler.ts
│   │   └── controllers/           ← Route handlers (parse input, call services)
│   │       └── user-controller.ts
│   │
│   ├── services/                  ← Business logic (no HTTP knowledge)
│   │   ├── user-service.ts        ← Business operations on User
│   │   ├── email-service.ts
│   │   └── payment-service.ts
│   │
│   ├── db/                        ← Database access (queries, models)
│   │   ├── models/
│   │   │   ├── user-model.ts
│   │   │   └── transaction-model.ts
│   │   └── migrations/            ← Database schema changes
│   │       ├── 001-create-users-table.sql
│   │       └── 002-add-email-index.sql
│   │
│   ├── types/                     ← Shared TypeScript types
│   │   ├── user.types.ts
│   │   └── api.types.ts
│   │
│   ├── utils/                     ← Reusable utilities
│   │   ├── date/
│   │   │   ├── format-date.ts
│   │   │   └── parse-date.ts
│   │   ├── validation/
│   │   │   ├── validate-email.ts
│   │   │   └── validate-phone.ts
│   │   └── crypto/
│   │       ├── hash-password.ts
│   │       └── verify-password.ts
│   │
│   ├── config/                    ← Environment-specific config
│   │   ├── database-config.ts
│   │   ├── server-config.ts
│   │   └── constants.ts
│   │
│   └── index.ts                   ← Entry point (exports public API)
│
├── tests/
│   ├── unit/                      ← Test individual functions
│   │   ├── services/
│   │   │   └── user-service.test.ts
│   │   └── utils/
│   │       ├── validate-email.test.ts
│   │       └── format-date.test.ts
│   │
│   ├── integration/               ← Test layer boundaries (API + DB)
│   │   ├── user-routes.test.ts
│   │   └── payment-flows.test.ts
│   │
│   ├── e2e/                       ← Test user workflows (optional)
│   │   ├── signup-flow.test.ts
│   │   └── payment-flow.test.ts
│   │
│   └── fixtures/                  ← Test data
│       ├── user-fixtures.ts
│       └── transaction-fixtures.ts
│
├── docs/
│   ├── architecture/
│   │   ├── system-design.md       ← Overall system
│   │   ├── decisions/             ← Architecture Decision Records
│   │   │   ├── ADR-0001-chose-postgresql.md
│   │   │   └── ADR-0002-api-authentication-strategy.md
│   │   └── user-service-design.md ← Feature-specific design
│   │
│   └── specs/
│       ├── 2026-05-03-user-comments.md
│       └── 2026-05-15-pagination.md
│
├── .project/
│   ├── codebase-health.md         ← This file (or in docs/)
│   ├── test-requirements.md       ← Test strategy
│   ├── approvals.md               ← Approval log
│   └── metrics.md                 ← Success metrics
│
├── .cursor/
│   ├── rules.md                   ← Path-scoped rules
│   ├── mcp.json                   ← MCP server config (if using)
│   └── tools.json                 ← Tool config (if using)
│
├── AGENTS.md                      ← Copied from LAF
├── CONVENTIONS.md                 ← Your customizations
├── .env.example                   ← Template for .env (never commit real .env)
├── .gitignore
├── package.json
└── README.md
```

---

### 3. Documented Decisions (ADRs)

```markdown
## Architecture Decision Records

**Purpose:** Record important decisions with tradeoffs (not just the decision, but WHY).

**Location:** docs/architecture/decisions/ADR-NNNN-*.md

**When to write an ADR:**
- Framework choice (why Django over FastAPI?)
- Authentication strategy (why JWT over sessions?)
- Database schema decision (why PostgreSQL over MongoDB?)
- Major refactor decision
- Anything that could confuse a future developer

**When NOT to write an ADR:**
- Obvious implementation details ("create a function to parse JSON")
- One-off bug fixes
- Formatting changes

**Template:**

```
# ADR-0001: Chose PostgreSQL Over MongoDB

## Status
Accepted (2026-05-03)

## Problem
We need a database. MongoDB is popular. PostgreSQL is traditional. 
Which should we use?

## Solution
PostgreSQL.

## Tradeoffs
**PostgreSQL:**
- Pro: Strong consistency, ACID transactions, complex queries
- Con: Less flexible schema, harder to scale horizontally

**MongoDB:**
- Pro: Flexible schema, built for horizontal scaling
- Con: Eventual consistency, weaker transaction support

## Why This Decision
Our data is relational (users → orders → items). 
We need ACID transactions for payments.
Consistency > flexibility for our domain.

## Consequences
- Migrations required for schema changes (1-2 hour process)
- Strong consistency gives us confidence in data
- More tooling available (ORMs, migrations, etc.)

## Revisit When
- If we need to handle 10M+ records without partitioning
- If ACID transactions become a bottleneck
```

**Keep a decision log:**

```
docs/architecture/decisions/
├── ADR-0001-chose-postgresql.md
├── ADR-0002-jwt-authentication.md
├── ADR-0003-why-no-caching-layer-yet.md   ← "Not yet" decisions are valuable
└── ADR-0004-monorepo-vs-microservices.md
```
```

---

### 4. Module Boundaries (What Goes Where)

```markdown
## Module Boundaries

### API Layer (src/api/)
- Only responsibility: HTTP (parsing requests, setting status codes, returning responses)
- Does NOT: Talk to database directly, implement business logic
- Example:
  ```typescript
  // ✅ Good: Parse, delegate, respond
  router.post('/users', async (req, res) => {
    try {
      const user = await userService.createUser(req.body);
      res.status(201).json(user);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  });
  
  // ❌ Bad: Business logic in the route
  router.post('/users', async (req, res) => {
    const hash = await bcrypt.hash(req.body.password, 10);
    await db.query('INSERT INTO users ...');
    // ^ This belongs in a service, not here
  });
  ```

### Service Layer (src/services/)
- Responsibility: Business logic (no HTTP, no database-specific code)
- Calls: Database models, utility functions
- Called by: API routes
- Example:
  ```typescript
  // ✅ Good: Business logic, no HTTP knowledge
  export class UserService {
    async createUser(data: CreateUserInput) {
      if (await this.emailExists(data.email)) {
        throw new Error('Email already in use');
      }
      return UserModel.create(data);
    }
  }
  ```

### Database Layer (src/db/)
- Responsibility: Queries, models, migrations
- Does NOT: Know about HTTP, contain business logic
- Example:
  ```typescript
  // ✅ Good: Data access only
  export class UserModel {
    static async create(data) {
      return db.query('INSERT INTO users ...', data);
    }
    static async findByEmail(email) {
      return db.query('SELECT * FROM users WHERE email = ?', email);
    }
  }
  ```

### Utils Layer (src/utils/)
- Responsibility: Pure functions, no side effects
- Examples: date formatting, validation, hashing, string manipulation
- Example:
  ```typescript
  // ✅ Good: Pure, reusable
  export function formatDate(date: Date, format: string): string {
    return format.replace('YYYY', date.getFullYear().toString());
  }
  ```
```

---

### 5. Code Comments (What to Document)

```markdown
## Comments: Only Explain "Why", Not "What"

❌ Bad comments (explain what the code obviously does):
```typescript
// Increment counter
counter++;

// Create user
const user = new User();

// Check if email is valid
if (!email.includes('@')) {
  throw new Error('Invalid email');
}
```

✅ Good comments (explain non-obvious "why"):
```typescript
// Cache for 5 minutes because the upstream API rate-limits at 1000/min
// Without caching, we'd hit the limit during morning traffic spike
const cached = cache.get(key);

// JWT instead of session cookies because we're scaling to multiple servers
// Sessions would require sticky load balancing or distributed cache
const token = jwt.sign({ userId: user.id }, SECRET);

// Retry with exponential backoff (1s, 2s, 4s, 8s) to handle
// temporary network hiccups without overwhelming the service
for (let i = 0; i < MAX_RETRIES; i++) {
  try { return attempt(); }
  catch (e) { await sleep(Math.pow(2, i) * 1000); }
}
```

**Rule of thumb:** If you have to explain what the code does, the code should be clearer. 
If you're explaining a tradeoff or constraint, the comment is valuable.

**Document in code:**
- Tradeoffs ("why not X?")
- Constraints ("must be under 100ms because...")
- Non-obvious dependencies ("breaks if Y changes because...")
- Intentional quirks ("looks wrong but is intentional because...")

**Don't document in code:**
- What the code obviously does
- Aspirational features ("TODO: add caching" unless actively working on it)
```

---

## Your Project's Health Standards

**Copy & customize this section:**

```markdown
## Our Codebase Standards (Project-Specific)

### Naming
- Functions: [verb][noun], describe what's returned, not how
- Files: lowercase, kebab-case, singular
- Directories: lowercase, kebab-case, plural

### Organization
- API layer: src/api/ (no business logic)
- Services: src/services/ (all business logic)
- Database: src/db/ (queries and models only)
- Utils: src/utils/ (pure functions)
- Tests: tests/ (unit/, integration/, e2e/)

### Documentation
- ADRs for all major decisions: docs/architecture/decisions/
- Feature design: docs/architecture/[feature]-design.md
- Specs: docs/specs/YYYY-MM-DD-[feature].md

### Boundaries
- No business logic in route handlers (src/api/)
- No database queries in services (use models)
- No HTTP knowledge in services or models

### Comments
- Explain "why" (tradeoffs, constraints, non-obvious intent)
- Don't explain "what" (code should be clear enough)
- Avoid: aspirational TODOs, obvious explanations
```

---

## Monitoring Codebase Health

**Every sprint, check:**

1. **New files follow naming conventions:** Files in `src/` use kebab-case, descriptive names
2. **No "misc" or "utils" directories:** If they're growing, refactor into named subdirectories
3. **ADRs exist for major decisions:** No big architectural changes without an ADR
4. **Comments explain "why", not "what":** Spot-check new code for obvious comments
5. **Layers aren't mixed:** API files don't query database directly; services don't depend on HTTP

---

## Next Steps

1. Copy this template to `.project/codebase-health.md` or `docs/codebase-health.md`
2. Customize for your stack (language, framework, database)
3. Share with team
4. Link to this doc in `CONVENTIONS.md` so agents know your standards
5. Review quarterly when patterns shift
