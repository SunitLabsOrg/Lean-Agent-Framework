# CONVENTIONS.md — Project-Specific Decisions

**Purpose:** Customize this file for your project. It defines your stack, style, and "ask before doing" checklist. One copy per project. Do not edit the framework version.

---

## Your Tech Stack

### Language & Framework

```
Language: [e.g., TypeScript, Python, Go]
Framework: [e.g., Next.js, Django, Gin]
Node version: [e.g., 18+, 20+]
Package manager: [npm, yarn, pnpm]
```

### Database

```
Primary DB: [e.g., PostgreSQL, MongoDB]
Cache layer: [e.g., Redis, in-memory]
Search: [e.g., Elasticsearch, PostgreSQL full-text]
```

### Deployment & Infrastructure

```
Cloud provider: [e.g., Vercel, AWS, GCP]
Infrastructure: [e.g., Serverless, containers, VMs]
CI/CD: [e.g., GitHub Actions, GitLab CI]
```

---

## File Organization

### Source Code Structure

```
src/
├── components/          [e.g., React components, if applicable]
├── pages/ or routes/    [e.g., Next.js pages or API routes]
├── lib/                 [utilities, helpers]
├── services/            [business logic, external API calls]
├── models/ or types/    [data models, TypeScript types]
├── middleware/          [auth, logging, etc.]
└── config/              [environment-specific config]
```

### Test Structure

```
tests/
├── unit/                [unit tests]
├── integration/         [integration tests]
├── e2e/                 [end-to-end tests]
└── fixtures/            [mock data, test utilities]
```

### Documentation Structure

```
docs/
├── architecture/        [system design, ADRs]
└── specs/               [feature specifications]
```

---

## Code Style & Conventions

### Naming

```
Variables: camelCase
Constants: UPPER_SNAKE_CASE
Classes: PascalCase
Files: kebab-case (e.g., user-service.ts) or camelCase (userService.ts)
```

### Formatting

```
Indentation: 2 spaces (or 4 spaces, or tabs — pick one)
Line length: 80 chars (or 120 chars)
Quotes: single or double (pick one, enforce with linter)
Semicolons: yes or no (pick one, enforce with linter)
```

### Linting & Formatting

```
Linter: [e.g., ESLint, pylint]
Formatter: [e.g., Prettier, black]
Config file: [.eslintrc.json, .prettierrc, etc.]
```

### Imports

```
Style: absolute imports or relative imports
Example: import UserService from "@/services/user-service"
(Use path aliases to avoid ../../ hell)
```

---

## Testing

### Framework & Tools

```
Test framework: [e.g., Jest, pytest, mocha]
Mocking library: [e.g., jest.mock, sinon, unittest.mock]
Coverage threshold: [e.g., 80% for critical paths, 60% overall]
```

### Testing Conventions

```
Test file naming: [e.g., *.test.ts, *_test.py, *_spec.js]
Test file location: [next to source, or in tests/ folder]
Test structure: [describe/it blocks, or unittest.TestCase, etc.]
```

### What Must Be Tested

```
- All public APIs and endpoints
- Business logic (the logic that would break your product if wrong)
- Error cases (what happens when something fails)
- Edge cases (boundary conditions, empty inputs, etc.)

What doesn't need tests:
- Trivial getters/setters
- Framework boilerplate
- Generated code
```

---

## Error Handling & Logging

### Error Handling Pattern

```
Pattern: [exceptions, result types, error codes]

Examples:
  - Throw exceptions (Node.js, Python): throw new Error("...")
  - Return error types (Go, Rust): return nil, err
  - Return result objects: { success: true/false, data, error }

Critical: Never swallow errors silently. Always surface meaningful messages.
```

### Logging

```
Style: structured logging or printf-style
Library: [e.g., winston, pino, spdlog]
Levels: ERROR, WARN, INFO, DEBUG
Pattern: log level + timestamp + context + message

Example: [2026-05-03T10:15:00Z] ERROR [UserService] Failed to fetch user 42: Connection timeout
```

---

## Database Conventions

### Schema

```
Naming: snake_case for tables, columns
IDs: uuid or auto-increment (pick one, use consistently)
Timestamps: created_at, updated_at (UTC, non-nullable)
Soft deletes: yes or no (pick one, use consistently)
```

### Migrations

```
Tool: [e.g., Flyway, Alembic, Knex]
Location: [migrations/ folder]
Naming: [YYYY-MM-DD-HH-mm-ss_description.sql]
Rule: every schema change is a migration, committed to Git
```

### Indexing

```
Rule: index all foreign keys
Rule: index frequently queried columns
Rule: avoid over-indexing (write performance penalty)
Rule: measure before optimizing
```

---

## API Conventions

### REST APIs

```
Versioning: URL (/v1/users) or header (Accept: application/vnd.api+v1+json)
Status codes: 200 OK, 201 Created, 400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found, 500 Internal Server Error
Response format:
{
  "success": true/false,
  "data": { ... } or null,
  "error": { "code": "ERROR_CODE", "message": "..." } or null
}

Error response format:
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email is required",
    "fields": { "email": "Email is required" }
  }
}
```

### Rate Limiting

```
Enabled: yes/no
Limits: [e.g., 100 requests per minute per IP]
Headers: X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset
```

---

## Security

### Secrets & Environment Variables

```
Location: .env (never in Git, use .env.example as template)
Pattern: APP_NAME_SECRET=value (uppercase, underscores)
Required vars: list them in .env.example with fake values

Critical secrets:
- API keys
- Database passwords
- JWT secret keys
- OAuth credentials
```

### Authentication & Authorization

```
Approach: [e.g., JWT, session cookies, OAuth]
Token storage: [e.g., secure HTTP-only cookie, localStorage]
Expiration: [e.g., 1 hour for access token, 7 days for refresh token]
```

### Sensitive Data

```
What to log: DO NOT log passwords, API keys, credit cards, SSNs, tokens
What to encrypt: PII, payment info, secrets at rest
Encryption: [e.g., AES-256, bcrypt for passwords]
```

---

## Ask Before Doing (Required Approval)

**Before making these changes, ask the team. Do not proceed unilaterally.**

### Database Changes

- [ ] Schema migrations (adding/removing columns or tables)
- [ ] Changing primary keys or constraints
- [ ] Changing soft-delete strategy
- [ ] Backfills or data corrections on production

### API Changes

- [ ] Removing endpoints (breaking change)
- [ ] Changing request/response contracts
- [ ] Adding required fields to API
- [ ] Changing status codes or error formats

### Authentication & Authorization

- [ ] Changing auth strategy (session → JWT, etc.)
- [ ] Adding new roles or permission levels
- [ ] Changing token expiration or refresh logic
- [ ] Disabling or removing auth mechanisms

### Infrastructure & Deployment

- [ ] Changing deploy strategy (blue-green, canary, etc.)
- [ ] Adding new environment variables
- [ ] Changing database connection strings or replicas
- [ ] Adding new external dependencies or services

### Performance-Critical Code

- [ ] Changing hot paths (code that runs on every request)
- [ ] Adding/removing caching layers
- [ ] Changing database query patterns on large tables
- [ ] Adding/removing background jobs

### Dependencies

- [ ] Adding a new external library (security, maintenance risk)
- [ ] Upgrading major versions of frameworks
- [ ] Removing dependencies that might be used elsewhere

---

## Development Workflow

### Git Conventions

```
Branch naming: feature/[description], bugfix/[description], hotfix/[description]
Commit messages: Conventional Commits (feat:, fix:, docs:, etc.)
PR requirements: code review by at least 1 person before merge
```

### Local Development

```
Setup: [command to get environment running, e.g., npm install && npm run dev]
Tests: [command to run tests]
Linting: [command to check style]
Building: [command to build for production]
```

### Before Committing

```
- [ ] Code follows style guidelines
- [ ] Tests pass locally
- [ ] Linting passes (no warnings or errors)
- [ ] Commit message is clear and follows conventions
- [ ] No secrets or environment-specific values in code
```

---

## Tools & Integrations

### Preferred AI Tools

```
Primary: [e.g., Cursor]
Secondary: [e.g., Claude Code]
Tertiary: [e.g., Copilot]
(Framework works with all; list your team's preferences)
```

### External Services

```
Monitoring: [e.g., Sentry, DataDog]
Analytics: [e.g., Mixpanel, Segment]
Email: [e.g., SendGrid, Mailgun]
Payments: [e.g., Stripe, Square]
(Add any third-party integrations)
```

---

## Project-Specific Notes

### Known Intentional Quirks

**List anything that looks wrong but is intentional:**

```
- [e.g., We don't use the ORM's relations because query performance is critical]
- [e.g., We version APIs in the URL instead of headers for easier debugging]
- [e.g., We use a monolith instead of microservices because team size and latency don't justify complexity]
```

### Performance Constraints

```
- Page load: < 2 seconds (target)
- API response: < 200ms p95 (target)
- Database query: < 100ms p95 (target)
- Large dataset sync: batch in 1000-item chunks
```

### Scale Assumptions

```
Current users: [e.g., 1K daily active]
Peak concurrent: [e.g., 50 users]
Data size: [e.g., 100M records in main table]
Scaling strategy: [when to add caching, when to shard, when to redesign]
```

---

## Contact & Questions

**If in doubt about any of the above, ask:**
- PM: [Name, Slack handle]
- Dev Lead: [Name, Slack handle]
- On-call: [How to escalate urgent issues]

---

## Version History

| Date | Updated by | Change |
|---|---|---|
| 2026-05-03 | [Your name] | Initial version |
| | | |

---

**Last updated:** 2026-05-03

**This file should be revisited every quarter and updated as your project evolves.**
