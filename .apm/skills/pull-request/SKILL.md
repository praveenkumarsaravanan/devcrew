---
name: pull-request
description: >
  Create pull requests with structured descriptions, test summaries, and
  JIRA ticket validation. Detects discrepancies between the implementation
  and the JIRA ticket and flags them before the PR is submitted.
---

# Pull Request

## Trigger

Activate this skill when:

- The user asks to create a pull request
- The user asks to open, submit, or push a PR
- Code is ready for review and needs a PR description

## Workflow

### 1. Gather Context

Run these commands in parallel to understand the full scope of changes:

```bash
git status
git log origin/trunk..HEAD --oneline
git diff origin/trunk...HEAD --stat
git diff origin/trunk...HEAD
```

Identify:
- All commits included in the PR (not just the latest)
- All files changed, added, or deleted
- The base branch (default: `trunk`)

### 2. Extract the JIRA Ticket

Find the JIRA ticket from:
1. The branch name (e.g., `feat/ENG-456-add-auth` → `ENG-456`)
2. Commit messages
3. The user's instructions

If no ticket is found, ask the user before proceeding.

### 3. Fetch JIRA Ticket Details

If the Atlassian MCP or Jira API is available, fetch the ticket:
- Summary / title
- Description and acceptance criteria
- Story points and priority
- Status (To Do, In Progress, Done)
- Subtasks if any

If the MCP is not available, ask the user to provide the ticket summary and acceptance criteria.

### 4. Analyze Implementation vs. JIRA Ticket

Compare what was implemented (from the diff) against what the ticket describes:

**Check for discrepancies:**

| Check | What to Look For |
|-------|-----------------|
| **Scope mismatch** | Code changes that go beyond the ticket's scope (unrelated refactors, extra features) |
| **Missing acceptance criteria** | Acceptance criteria in the ticket that are not addressed by the code changes |
| **Partial implementation** | Ticket describes multiple requirements but only some are implemented |
| **Different approach** | Implementation takes a fundamentally different approach than what the ticket describes |
| **Missed subtasks** | Subtasks on the ticket that have no corresponding code changes |

**If discrepancies are found:**

1. List each discrepancy clearly with what the ticket says vs. what was implemented
2. Recommend whether the JIRA ticket or the code should be updated
3. Ask the user how they want to proceed:
   - Update the JIRA ticket to match the implementation
   - Note the discrepancies in the PR description
   - Hold the PR until the gaps are addressed
4. Only proceed with PR creation after the user acknowledges the discrepancies

### 5. Identify Test Coverage

Scan the diff for test-related changes:
- New or modified test files
- Test function names and what they cover
- Types of tests: unit, integration, e2e

If no tests are found in the diff:
- Flag this explicitly in the PR description
- Ask the user whether tests are tracked separately or were intentionally omitted

### 6. Construct the PR Description

Use the following template:

```markdown
## Summary

<!-- 2-3 sentences describing what this PR does and why -->

## JIRA Ticket

[<TICKET-KEY>](https://<ghe-host>/path/to/ticket) — <ticket summary>

## Changes

<!-- Bulleted list of meaningful changes, grouped by area -->

- **<area>**: <what changed and why>
- **<area>**: <what changed and why>

## Discrepancies

<!-- Only include if discrepancies were found in Step 4 -->

- <discrepancy description and resolution>

## Testing

### Tests Added/Modified

- `<test file>`: <what is tested>

### Manual Testing

- [ ] <manual test step and expected result>

### Test Results

<!-- Summary of test runs if available -->

## Checklist

- [ ] Code follows org coding standards
- [ ] Commit messages match commitlint format
- [ ] No secrets or credentials in the diff
- [ ] JIRA ticket status updated
- [ ] Tests cover new/changed logic
- [ ] Documentation updated (if applicable)
- [ ] Breaking changes documented (if applicable)
```

### 7. Create the PR

Push the branch and create the PR:

```bash
git push -u origin HEAD

gh pr create \
  --base trunk \
  --title "<type>(<scope>): <JIRA-ticket>, <short description>" \
  --body "$(cat <<'EOF'
<constructed PR description from Step 6>
EOF
)"
```

The PR title must follow the same commitlint format as commit messages since squash merges use the PR title as the commit message.

### 8. Post-Creation

After the PR is created:
- Return the PR URL to the user
- If discrepancies were found, remind the user to update the JIRA ticket
- If no tests were included, note this as a follow-up item

## Guardrails

- **Never create a PR without analyzing the diff.** Read all changes, not just the latest commit.
- **Always validate against the JIRA ticket.** If the Atlassian MCP is unavailable, ask the user for ticket details manually.
- **Flag missing tests explicitly.** Do not silently skip the testing section.
- **Do not suppress discrepancies.** Always surface mismatches between the ticket and the implementation, even if minor. Let the user decide how to handle them.
- **PR title must match commitlint format.** The server-side hook applies to squash merge commits which use the PR title.
- **Never push to trunk directly.** Always create the PR against trunk from a feature branch.
- **Include the full checklist.** Do not remove checklist items — leave them unchecked if not applicable so reviewers can see what was considered.
