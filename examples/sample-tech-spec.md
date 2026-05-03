# Technical Design: User Comments

## Overview

Implement a comment system allowing authenticated users to comment on posts, edit/delete their own comments, and view all comments on a post. Uses existing PostgreSQL, monolithic architecture.

## System Architecture

### Components

1. **Database Layer**
   - `comments` table: stores comment data
   - Relationships: comment → post (foreign key), comment → user (foreign key)

2. **API Layer**
   - `POST /posts/:id/comments` — create comment
   - `GET /posts/:id/comments` — list comments for post (paginated)
   - `PATCH /comments/:id` — edit comment (owner only)
   - `DELETE /comments/:id` — delete comment (soft delete, owner only)

3. **Service Layer**
   - `CommentService`: business logic (validation, authorization, persistence)
   - `PermissionCheck`: verifies user owns comment before edit/delete

4. **UI Layer** (phase 2, not included in v1)
   - Comment form (create)
   - Comment list (read)
   - Edit/delete buttons (update/delete)

### Data Model

```sql
CREATE TABLE comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id),
  text TEXT NOT NULL CHECK (length(text) >= 1 AND length(text) <= 5000),
  is_deleted BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(id)
);

CREATE INDEX idx_comments_post_id ON comments(post_id);
CREATE INDEX idx_comments_user_id ON comments(user_id);
CREATE INDEX idx_comments_created_at ON comments(created_at);
```

### Data Flow

```
User submits comment form
  ↓
API: POST /posts/:123/comments { text: "..." }
  ↓
Middleware: Verify authentication (JWT token)
  ↓
Controller: Extract user_id from token
  ↓
Service: Validate text (1-5000 chars, no URLs)
  ↓
Database: INSERT into comments table
  ↓
Response: { id, text, user_id, created_at }
  ↓
UI: Display comment in list
```

### External Integrations

None in v1.

## Implementation Plan

### Phase 1: Core API (Days 1-2)

1. Create database migration: `comments` table
2. Implement API endpoints (create, read, update, delete)
3. Add authentication checks (JWT verification)
4. Add input validation (text length, URL filtering)
5. Write unit tests
6. Deploy to staging

### Phase 2: Pagination (Day 3)

1. Implement pagination: GET /posts/:id/comments?page=1&limit=20
2. Tests: verify page boundaries, edge cases
3. Deploy

### Phase 3: Soft Delete (Day 3)

1. Implement soft delete: flag comment as deleted, don't remove
2. API: return "[deleted]" for deleted comments
3. Tests: verify deleted comments don't disappear

## Tradeoffs & Decisions

### Decision: Monolith vs. Microservices

**Chosen:** Monolith (same codebase as posts service)

**Why:**
- Team size: 2 developers (too small for microservices)
- Latency: Comments always fetched with posts (co-located good)
- Maintenance: Single deployment pipeline

**Costs:**
- Couples comments domain to posts domain
- Can't scale comment service independently if needed later
- Must coordinate database migrations

**When this breaks:**
- If comment processing becomes 50% of CPU (can then extract to separate service)
- If we have 10+ engineers on different teams (easier with microservices)

---

### Decision: PostgreSQL vs. NoSQL

**Chosen:** PostgreSQL (existing)

**Why:**
- Comments are relational (comment ← → user, post)
- ACID guarantees (concurrent deletes won't corrupt data)
- Already deployed, team knows it

**Costs:**
- Less flexible schema (must migrate for changes)
- Harder to scale horizontally (but not needed yet)

**When this breaks:**
- If we need to store semi-structured data (nested replies, rich metadata)
- If scale needs 100K comments/sec (sharding gets complex)

---

### Decision: Soft Delete vs. Hard Delete

**Chosen:** Soft Delete

**Why:**
- Preserves audit trail (can see what was deleted)
- Referential integrity (no orphaned replies later)
- Can restore deleted comments if user accidentally deletes

**Costs:**
- Extra column, slightly larger indexes
- "Deleted" comments still take space
- Must filter `is_deleted = false` on all queries

**When this breaks:**
- If storage becomes expensive (can archive old deleted comments)

---

### Decision: UUID vs. Auto-Increment IDs

**Chosen:** UUID

**Why:**
- Prevents race conditions: two users creating comments simultaneously get different IDs
- Can pre-generate IDs client-side if needed
- Secure: IDs are not guessable

**Costs:**
- Larger storage (16 bytes vs. 8 bytes for bigint)
- Slightly slower comparisons
- Less human-readable

**When this breaks:**
- Probably never for this scale

---

## Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
|---|---|---|---|
| Concurrent comment creation race condition | Data corruption / duplicate IDs | LOW | UUID primary key prevents this |
| User tries to edit/delete someone else's comment | Security breach | MEDIUM | Auth middleware + permission check |
| Comment text XSS injection (if rendered to HTML) | Security breach | HIGH | Use text renderer (not HTML), escape output |
| URL spam in comments ("click here -> ...") | User experience | HIGH | Block URLs in comment text (regex filter) |
| Post deleted, orphaned comments | Data issue | LOW | Foreign key ON DELETE CASCADE |
| Database down during comment creation | 500 error | LOW | Application should handle gracefully |

## Assumptions

- [ ] Authentication layer (JWT token) exists and is working
- [ ] `users` table has `id`, `name` columns
- [ ] `posts` table has `id`, `title` columns
- [ ] PostgreSQL is available on this project (verified: ✅)
- [ ] Database migrations auto-run on deploy (verified: ✅)
- [ ] Response time target < 200ms p95 applies here (verified: ✅)
- [ ] Users won't create 1000+ comments per post (reasonable assumption)

## Unknowns & Experiments Needed

- How many concurrent comments per post can PostgreSQL handle? (Need load test)
- Will comment fetch slow down post load? (Need to profile with real data)
- Do we need to cache comment list? (Measure after shipping)

## Reversibility

- Can we remove comment feature? **Partially.** Requires data migration to drop table (safe).
- Can we change from PostgreSQL to NoSQL? **Hard.** Would require rewriting queries.
- Can we switch to microservice? **Yes.** Can extract later if needed.

---

<!-- ARCH-APPROVED by Dev Lead, 2026-05-03 11:30 AM -->
