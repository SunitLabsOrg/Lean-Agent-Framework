# Feature: User Comments

## Problem

Users want to discuss posts, but currently have no way to add comments. They must use external channels (email, Slack) to discuss, which fragments conversation and context.

## Target User

Active readers of blog posts who want to engage with other readers and authors.

## Success Criteria

- Users can add a comment to any post
- Users see all existing comments on a post
- Users can edit or delete their own comments
- Comment author and timestamp are visible
- Post author can see all comments on their posts

## Scope

**In scope:**
- Comments on posts (text only)
- Create comment: authenticated user, 1-5000 char text
- View comments: anyone, paginated if 100+ comments per post
- Edit own comment (text, timestamp updated)
- Delete own comment (soft delete, shows "[deleted]")
- Basic spam filter: no links in comment text v1
- Notification in v1: none (PM will decide in Phase 2)

**Out of scope:**
- Nested replies (replies to comments) → Phase 2
- AI moderation / spam detection → Phase 2
- Email notifications → Phase 2
- Comment reactions (likes) → Phase 2
- Comment search / filtering → Phase 2
- Rich text formatting → Phase 2

## Acceptance Criteria

- [ ] Users can create a comment on a post (UI + API working)
- [ ] Comments are persisted to database
- [ ] Comments display on post with author name, timestamp
- [ ] Users can edit their comment (text, timestamp shows "edited")
- [ ] Users can delete their comment (soft delete)
- [ ] Non-author cannot edit/delete others' comments
- [ ] API rate limiting prevents abuse (100 comments per user per hour max)
- [ ] Comment text is validated (1-5000 chars, no URLs)
- [ ] Tests pass (unit + integration)
- [ ] Code review passes (security, conventions)
- [ ] Feature flag exists (can disable if bugs found)

## Open Questions

- Do we notify the post author when someone comments? (Ask product team)
- Should users be able to mention/tag others? (Low priority, Phase 2)
- Should comments be ranked by likes/helpfulness? (No for v1, maybe Phase 2)

---

<!-- APPROVED by PM [Name], 2026-05-03 10:15 AM -->
