---
name: git-release-tag
description: >
  Tag and publish a new version of the package. Reads the current version from
  apm.yml, auto-increments it (patch, minor, or major), blocks duplicate tags,
  creates a GitHub release with changelog, and pushes — all with explicit user
  confirmation.
---

# Git Release & Tag

## Trigger

Activate this skill when:

- The user asks to release, tag, or publish a new version
- The user asks to bump the version
- The user says "cut a release" or "ship it"
- A set of changes has been merged and needs a version tag

## Available Scripts

- `**scripts/release.sh**` — Reads the current version from `apm.yml`, computes the next version, generates a changelog from commits since the last tag, blocks duplicate tags, updates the file, commits, tags, pushes, and creates a GitHub release.

> **Note:** All script paths below are relative to the repository root. The full path is `.apm/skills/git-release-tag/scripts/release.sh`, but `apm.yml` registers the script as `release`, so you can also invoke it via `apm run release`.

## Workflow

### 1. Determine the Increment Type

Default to **patch** unless the user explicitly requests `minor` or `major`. Do not ask — just use `patch`. Only use a different increment when the user names it directly (e.g., "minor release", "major bump").

| Type      | When to use                                                       |
| --------- | ----------------------------------------------------------------- |
| **patch** | Default. Fixes, updates, documentation, or any unlabeled release  |
| **minor** | Only when user explicitly requests. New skills, agents, prompts, hooks, or non-breaking additions |
| **major** | Only when user explicitly requests. Breaking changes to primitives that consumers may have overridden |

### 2. Pre-flight Checks

Before running the release script, verify conditions and surface any blockers to the user:

```bash
git rev-parse --abbrev-ref HEAD
git status --porcelain
git fetch --tags
```


| Condition                | Action                                                         |
| ------------------------ | -------------------------------------------------------------- |
| Not on `trunk` or `main` | Ask the user to switch branches or confirm this is intentional |
| Dirty working tree       | Ask the user to commit or stash before continuing              |
| Behind remote            | Ask the user to pull first: `git pull origin trunk`            |


### 3. Preview the Release (Dry Run)

Always run a dry run first so the user can see the plan and confirm:

```bash
bash .apm/skills/git-release-tag/scripts/release.sh --dry-run --json --ticket ISSUE-XXX
```

When the user specifies `minor` or `major`:

```bash
bash .apm/skills/git-release-tag/scripts/release.sh minor --dry-run --json --ticket ISSUE-XXX
```

The `--ticket` flag embeds the ticket ID in the version bump commit message to satisfy the recommended commit convention. Always include it.

The `--json` flag outputs a structured summary to stdout:

```json
{"increment":"patch","current_version":"1.1.2","next_version":"1.1.3","tag":"v1.1.3","branch":"trunk","dry_run":true,"changes":"- feat: ..."}
```

Present the plan to the user and ask for explicit confirmation before proceeding.

### 4. Execute the Release

After the user confirms the dry-run plan, run the script with `--confirm` to skip interactive prompts (agents cannot respond to TTY input):

```bash
bash .apm/skills/git-release-tag/scripts/release.sh --confirm --ticket ISSUE-XXX
```

When the user specifies `minor` or `major`:

```bash
bash .apm/skills/git-release-tag/scripts/release.sh minor --confirm --ticket ISSUE-XXX
```

The script will:

1. Update `apm.yml` with the new version
2. Commit: `chore(release): ISSUE-XXX, bump version to X.Y.Z`
3. Generate a changelog from commits since the previous tag
4. Create an annotated tag `vX.Y.Z` with the changelog in the tag message
5. Push the commit and tag to origin
6. Create a GitHub release with the changelog as the release body

If the user wants to tag without pushing (e.g., to review first), add `--no-push`:

```bash
bash .apm/skills/git-release-tag/scripts/release.sh --confirm --no-push --ticket ISSUE-XXX
```

If the user wants to skip the GitHub release (tag only), add `--no-release`:

```bash
bash .apm/skills/git-release-tag/scripts/release.sh --confirm --no-release --ticket ISSUE-XXX
```

### 5. Post-Release Verification

After the script completes, confirm the tag and release exist on the remote:

```bash
git ls-remote --tags origin | grep "vX.Y.Z"
gh release view vX.Y.Z
```

Inform the user how consumers receive the update:

- Consumers on `ref: trunk` get it automatically on next `apm deps update`
- Consumers pinned to a tag must update their `apm.yml` to `ref: vX.Y.Z`
- Consumers watching the repo will receive a GitHub notification about the new release

### Exit Codes

The script uses distinct exit codes — use these to decide the next action:


| Code | Meaning                                                               |
| ---- | --------------------------------------------------------------------- |
| `0`  | Success                                                               |
| `1`  | Usage error or unexpected failure                                     |
| `2`  | Pre-flight check failed (dirty tree, wrong branch, missing `apm.yml`) |
| `3`  | Tag already exists (duplicate release blocked)                        |


If exit code is `3`, inform the user that this version is already tagged and suggest incrementing to the next version instead.

## See Also

- **`/release-readiness`** — Before tagging, run this prompt to assess whether the release candidate passes the go/no-go checklist.
- **`/monitoring-plan`** — After release, use this prompt to verify SLOs, alerts, and runbooks are in place for the new version.
- **`/devops-plan`** — If the release changes deployment strategy or infrastructure, run this prompt to plan the rollout.

## Guardrails

- **Never run without a dry run first.** Always preview the release plan and get user confirmation before executing.
- **Always pass `--confirm` when executing.** The agent cannot respond to interactive prompts. Omitting `--confirm` will hang the session.
- **Always pass `--ticket` with the ticket ID.** The recommended commit convention rejects commits without a ticket. Omitting `--ticket` will cause the push to fail.
- **Never tag from a feature branch.** Releases come from `trunk` or `main` only. If the user insists on tagging from another branch, warn them explicitly and require double confirmation.
- **Never re-tag an existing version.** If the tag already exists (exit code `3`), do not bypass it. Increment to a new version instead.
- **Never force-push tags.** If a tag needs correction, create a new version. Deleting and re-creating tags breaks consumers who already resolved the old tag.
- **Always verify the push succeeded.** After execution, confirm the tag is visible on the remote before reporting success.
- **Never delete a GitHub release.** If a release has incorrect notes, edit it with `gh release edit`. Deletion confuses consumers who already saw the notification.

