# Layer 4: MCP Servers Configuration Template

**Purpose:** This template helps teams decide which external tools to wire into their agent workflow via MCP (Model Context Protocol).

---

## Layer 4 Decision Checklist

**Is MCP integration needed?**

- [ ] No — Team provides context manually in chat (simplest, OK for small teams)
- [ ] Yes — Wire specific external tools for real-time data access

---

## If YES: Which Tools to Wire?

Check the tools your team actually uses. Don't wire tools you don't use; it adds complexity.

### Communication & Collaboration

| Tool | Use Case | Benefit | Setup Effort |
|------|----------|---------|--------|
| **Slack** | Team decisions, deployment notifications, approval tracking | Agent sees decisions made in Slack without asking team to copy/paste | Medium |
| **GitHub** | PR history, CI status, deployment logs | Agent understands context of related PRs, deployment status | Low |
| **Linear** | Issue tracking, scope, acceptance criteria | Agent reads exact scope from Linear instead of from chat | Low |

### Data & Metrics

| Tool | Use Case | Benefit | Setup Effort |
|------|----------|---------|--------|
| **Datadog** | Production logs, metrics, errors, APM traces | Agent diagnoses issues by querying production data in real time | High |
| **Postgres / MySQL** | Schema, test data queries | Agent understands data structure without asking, writes better queries | Medium |
| **Sentry** | Error tracking, stack traces | Agent queries error patterns, root cause analysis | Medium |

### Development & Infrastructure

| Tool | Use Case | Benefit | Setup Effort |
|------|----------|---------|--------|
| **Databricks** | SQL notebooks, data exploration | Agent runs queries, builds dashboards, explores data | High |
| **AWS / GCP / Azure** | Infrastructure, deployment, logging | Agent checks infrastructure state, deployment history | High |
| **Docker Hub / ECR** | Container registry, image history | Agent pulls deployment history, image tags | Low |

---

## Your Team's MCP Configuration

**Fill this out at project start:**

```markdown
## Tools We're Wiring

### Communication
- [ ] Slack
- [ ] GitHub
- [ ] Linear / Jira
- [ ] Other: ____

### Data & Metrics
- [ ] Datadog
- [ ] PostgreSQL / MySQL
- [ ] Sentry
- [ ] Other: ____

### Infrastructure
- [ ] Databricks
- [ ] AWS / GCP / Azure
- [ ] Docker Hub / ECR
- [ ] Other: ____

## Why We Chose These

For each tool checked above, write 1 sentence:
- Slack: [why this helps your team]
- GitHub: [why this helps your team]
- etc.

## Setup Steps

1. Create `.cursor/mcp.json` (or equivalent for your tool)
2. Add API keys to `.env.mcp` (never commit this file)
3. Test MCP connection: agent should query data without manual context
4. Document how to query each tool (e.g., "To check prod errors, ask: 'Query Sentry for 500 errors in the last hour'")
```

---

## Example: Minimal MCP Setup

For a small team with one data source:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["@cursor-mcp/github"],
      "env": { "GITHUB_TOKEN": "${GITHUB_TOKEN}" }
    },
    "postgres": {
      "command": "npx",
      "args": ["@cursor-mcp/postgres"],
      "env": { 
        "DATABASE_URL": "${DATABASE_URL}",
        "DB_USER": "${DB_USER}",
        "DB_PASSWORD": "${DB_PASSWORD}"
      }
    }
  }
}
```

---

## Example: Comprehensive MCP Setup

For a team with multiple data sources:

```json
{
  "mcpServers": {
    "slack": {
      "command": "npx",
      "args": ["@cursor-mcp/slack"],
      "env": { "SLACK_BOT_TOKEN": "${SLACK_BOT_TOKEN}" }
    },
    "github": {
      "command": "npx",
      "args": ["@cursor-mcp/github"],
      "env": { "GITHUB_TOKEN": "${GITHUB_TOKEN}" }
    },
    "linear": {
      "command": "npx",
      "args": ["@cursor-mcp/linear"],
      "env": { "LINEAR_API_KEY": "${LINEAR_API_KEY}" }
    },
    "datadog": {
      "command": "npx",
      "args": ["@cursor-mcp/datadog"],
      "env": { 
        "DD_API_KEY": "${DD_API_KEY}",
        "DD_APP_KEY": "${DD_APP_KEY}"
      }
    },
    "postgres": {
      "command": "npx",
      "args": ["@cursor-mcp/postgres"],
      "env": { "DATABASE_URL": "${DATABASE_URL}" }
    }
  }
}
```

---

## Environment File (.env.mcp)

**IMPORTANT: Do NOT commit this file. Add `.env.mcp` to `.gitignore`.**

```env
# GitHub
GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxx

# Slack
SLACK_BOT_TOKEN=xoxb-xxxxxxxxxxxx

# Linear
LINEAR_API_KEY=lin_api_xxxxxxxxxxxxxxxxxxxx

# Datadog
DD_API_KEY=xxxxxxxxxxxxxxxxxxxx
DD_APP_KEY=xxxxxxxxxxxxxxxxxxxx

# PostgreSQL (from your deployment)
DATABASE_URL=postgresql://user:password@host:5432/dbname
DB_USER=your_db_user
DB_PASSWORD=your_db_password
```

---

## Common Mistakes

❌ **Wiring tools you don't use** — Extra configuration, adds complexity, confuses agents
✅ **Start small** — Wire 1-2 tools first, expand after you see the benefit

❌ **Hardcoding API keys in `.cursor/mcp.json`** — Security risk
✅ **Use environment variables** — Keys in `.env.mcp`, referenced in config

❌ **Forgetting to git-ignore `.env.mcp`** — Credentials leaked in repo
✅ **Add to `.gitignore` immediately** — Never commit secrets

❌ **Wiring MCP tools without documenting queries** — Agents don't know how to use them
✅ **Document usage** — "To check prod errors, ask: 'Query Sentry for 500s in the last hour'"

---

## When to Add More Tools

**Add more tools when:**
- Team asks agent questions that require external data (e.g., "What's the deployment status?")
- Agent could save time by querying data instead of team providing context
- Setup time is under 1 hour per tool

**Don't add tools for:**
- One-off questions (just answer in chat)
- Rarely used integrations (maintenance overhead not worth it)

---

## Monitoring & Maintenance

After setting up MCP servers:

1. **Weekly:** Check that agent can query each tool without errors
2. **Monthly:** Review which tools agents actually use (remove unused ones)
3. **Quarterly:** When tooling changes, update or remove MCP configs

---

## Next Steps

1. Fill out the "Tools We're Wiring" checklist above
2. Create `.cursor/mcp.json` with chosen tools
3. Create `.env.mcp` with API keys
4. Add `.env.mcp` to `.gitignore`
5. Test: Ask agent to query each tool
6. Document how agents should query each tool
