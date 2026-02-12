# Task System

The skill uses a filesystem-based task queue to track work items and enable parallel agent execution. All task state lives in `.compliance/tasks/`.

## Task File Format

Each task is a file at `.compliance/tasks/{task-id}.md` with YAML frontmatter:

```markdown
---
id: gen-access-control
category: generation
status: pending
policy: access-control
locked_by:
locked_at:
created: 2025-01-15T00:00:00Z
---

# Generate access-control policy

Run Steps 4-5-6 for the access-control policy using answers from `.compliance/answers/access-control.md`.

## Acceptance Criteria
- Policy file saved to `.compliance/policies/access-control.md`
- status.md Policies table updated with `generated` status
- Policy review task created
- Manual evidence tasks created for non-automated evidence items
```

## Task Categories and ID Conventions

| Category | `category` value | ID Pattern | Example |
|----------|-----------------|-----------|---------|
| Policy generation | `generation` | `gen-{policy-id}` | `gen-access-control` |
| Policy review | `review` | `review-{policy-id}` | `review-access-control` |
| Evidence automation | `evidence-auto` | `auto-{tool-or-provider}` | `auto-okta`, `auto-aws` |
| Manual evidence | `evidence-manual` | `evidence-{policy-id}-{evidence-name-kebab}` | `evidence-access-control-mfa-enforcement` |

## Task Status Values

| Status | Meaning |
|--------|---------|
| `pending` | Not started, available to claim |
| `in_progress` | Claimed by an agent (check `locked_by`) |
| `done` | Completed successfully |
| `blocked` | Cannot proceed (dependency or user input needed) |

## Locking Protocol

Agents claim tasks by writing to the `locked_by` field. This prevents two agents from working on the same task.

1. **Read** the task file — check that `locked_by` is empty and `status` is `pending`
2. **Claim** — write `locked_by: {agent-id}`, `locked_at: {ISO timestamp}`, `status: in_progress`
3. **Do the work** described in the task body
4. **Complete** — write `status: done`, clear `locked_by` and `locked_at`
5. **Update `status.md`** — recalculate the Summary table counts by reading all task files

If `locked_by` is already set, skip this task and move to the next available one.

## Keeping status.md in Sync

After any task status change, update the Summary table in `.compliance/status.md`:
1. Read all `.compliance/tasks/*.md` frontmatter
2. Group by `category`, count by `status`
3. Write updated counts to the Summary table
