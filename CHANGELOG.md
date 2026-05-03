# Changelog

All notable changes to Lean Agent Framework (LAF) are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added

#### 2026-05-03: GitHub Actions Integration & PR Review Clarification

**New Documentation:**
- **`docs/automation/PR-COMMENTS-VS-MARKDOWN.md`** (280 lines)
  - Clarifies the distinction between PR comments and markdown reports
  - Explains when to use each (not duplicates, different purposes)
  - Shows how they work together in feature development
  - Provides decision matrix for different team sizes
  - Implementation patterns (minimal/automated/formal)
  - FAQ section

**Updated:**
- **`INDEX.md`** — Added reference to PR-COMMENTS-VS-MARKDOWN.md in header

**Why this matters:**
- Teams often ask: "Why do we need both PR comments AND review-report.md?"
- This document clarifies the complementary role of each
- PR comments = real-time feedback (development phase)
- Markdown reports = formal approval records (archive phase)
- Keeps LAF focused on workflow, not specific tools (GitHub Actions optional)

**Note:** This is hybrid approach — clarification only, no workflow templates added yet. Teams can automate PR comments with GitHub Actions using their own patterns, or keep it manual.

**New Documents:**
- **`CONTEXT-LAYERS.md`** (399 lines)
  - Complete reference guide for the 6-layer agent context model
  - Explains what LAF provides (Layers 1–3: workflow, skills, approval gates)
  - Explains what teams customize (Layers 4–6: external tools, codebase structure, test requirements)
  - Governance model for each layer (who writes, who updates, scope)
  - Onboarding checklists for new projects
  - FAQ and decision guidance

**New Template Files (in `templates/`):**
- **`LAYER-4-MCP-TEMPLATE.md`** (150 lines)
  - How to decide which external tools to wire (Slack, GitHub, Linear, Datadog, PostgreSQL, Sentry, etc.)
  - Example `.cursor/mcp.json` configurations (minimal and comprehensive)
  - `.env.mcp` template with API key placeholders
  - Common mistakes and maintenance guidelines
  - When to add more tools

- **`LAYER-5-CODEBASE-HEALTH-TEMPLATE.md`** (350 lines)
  - Naming conventions for functions, files, and directories
  - File organization structure with examples for different stacks
  - Architecture Decision Record (ADR) template and process
  - Module boundaries (what goes in API, services, database layers)
  - Code comment guidelines (explain "why", not "what")
  - Health monitoring checklist (quarterly review)

- **`LAYER-6-TEST-TEMPLATE.md`** (400 lines)
  - Coverage targets (unit, integration, E2E) with rationale
  - Test file organization (colocated unit tests, centralized integration/E2E)
  - High-risk areas requiring 100% coverage (auth, payments, deletions, migrations)
  - Pre-commit hooks and CI/CD gate setup (GitHub Actions example)
  - Test data strategy (fixtures and factories)
  - Example test code (unit, integration, E2E patterns)
  - Common mistakes and monitoring guidance

**Why this matters:**
- **Layer 4 (MCP):** Teams don't have to figure out external tool integration; clear examples for popular tools prevent hardcoded secrets
- **Layer 5 (Codebase):** Agents dramatically improve when code is clean and well-named; teams document architectural decisions; clear patterns accelerate code review and onboarding
- **Layer 6 (Tests):** Tests are the agent's verification layer; clear coverage targets prevent regression; high-risk area testing reduces production bugs

### Changed

**Documentation Updates:**
- **`README.md`**
  - Updated line 5 intro to reference `CONTEXT-LAYERS.md` for the 6-layer model
  - Updated documentation map table to include `CONTEXT-LAYERS.md` (positioned after README, before INDEX)
  - Now reads: "Start with **this README** for overview and setup; use **[INDEX.md](INDEX.md)** for skills, workflows, and gates; **[CONTEXT-LAYERS.md](CONTEXT-LAYERS.md)** for the 6-layer model..."

- **`INDEX.md`**
  - Updated header reference to link to `CONTEXT-LAYERS.md`
  - Now reads: "To understand the 6-layer agent context model, see [CONTEXT-LAYERS.md](CONTEXT-LAYERS.md)"

**Why:**
- New teams discover the context layers early in onboarding
- Reduces time spent asking "what context should we set up?"

---

## [Future Versions]

### Planned for Consideration

- Template for MCP server implementations (ready-to-run examples)
- Pre-configured ADR templates per industry (SaaS vs. data vs. infrastructure)
- Test suite generators (scaffold tests based on codebase structure)
- Layer health assessment tool (automatic scan of codebase/tests/documentation)

---

## How to Use This Changelog

**For teams adopting LAF:**
1. Read this changelog to see what's available
2. Start with `README.md` for setup
3. Read `CONTEXT-LAYERS.md` to understand all 6 layers
4. Use templates for Layers 4–6 based on your project needs

**For contributors to LAF:**
1. Update this changelog when adding/changing documentation
2. Use section headers: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`
3. Include dates and brief "why" for each change
4. Keep entries focused and scannable

---

## Version History

### [Unreleased] — 2026-05-03
- 6-Layer Agent Context Framework added (see above)

---

## Frequently Asked Questions

**Q: Do I have to implement all 6 layers?**

A: No. Layers 1–3 are LAF (always provided). Layers 4–6 are optional:
- Solo dev: Layers 1–3 only
- Growing team: Add Layer 5 (codebase health)
- External dependencies: Add Layer 4 (MCP servers)
- High-risk code: Add Layer 6 (test requirements)

**Q: Can I customize the templates?**

A: Yes. They're templates, not requirements. Adapt them for your stack, language, and practices.

**Q: Where should I put these in my project?**

A: Copy relevant sections into:
- `.project/codebase-health.md` (Layer 5)
- `.cursor/mcp.json` (Layer 4)
- `.project/test-requirements.md` (Layer 6)

**Q: Do agents know about these layers?**

A: Not by default. Add links to these docs in your `CONVENTIONS.md` so agents reference them.

---

## Next Steps

1. **Read** `CONTEXT-LAYERS.md` to understand the model (20 minutes)
2. **For new projects:** Use checklists to decide which Layers 4–6 to implement
3. **For existing projects:** Assess your current state against all 6 layers
4. **Use templates** as starting points, customize for your stack
5. **Review quarterly:** Layers 4–6 evolve as project needs change

---

**Key Principle:** LAF is now a complete agent context framework, not just a workflow framework. Teams understand what LAF provides and what they need to build on top of it.
