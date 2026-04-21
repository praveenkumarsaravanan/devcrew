---

## name: release
description: >
  Tag and publish a new version of the package. Reads the current version from
  apm.yml, auto-increments it (patch, minor, or major), blocks duplicate tags,
  and pushes the release — all with explicit user confirmation.

# Release

## Trigger

Activate this skill when:

- The user asks to release, tag, or publish a new version
- The user asks to bump the version
- The user says "cut a release" or "ship it"
- A set of changes has been merged and needs a version tag

## Available Scripts

- `**scripts/release.sh**` — Reads the current version from `apm.yml`, computes the next version, blocks duplicate tags, updates the file, commits, tags, and pushes.

## Workflow

### 1. Determine the Increment Type

Ask the user which increment to apply unless they have already specified it:


| Type      | When to use                                                       |
| --------- | ----------------------------------------------------------------- |
| **patch** | Fixes to existing skills, instructions, prompts, or documentation |
| **minor** | New skills, agents, prompts, hooks, or non-breaking additions     |
| **major** | Breaking changes to primitives that consumers may have overridden |


If the user describes their changes but doesn't name an increment, infer it from the table above and confirm before proceeding.

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
bash scripts/release.sh <patch|minor|major> --dry-run --json
```

The `--json` flag outputs a structured summary to stdout:

```json
{"increment":"minor","current_version":"1.0.0","next_version":"1.1.0","tag":"v1.1.0","branch":"trunk","dry_run":true}
```

Present the plan to the user and ask for explicit confirmation before proceeding.

### 4. Execute the Release

After the user confirms the dry-run plan, run the script with `--confirm` to skip interactive prompts (agents cannot respond to TTY input):

```bash
bash scripts/release.sh <patch|minor|major> --confirm
```

The script will:

1. Update `apm.yml` with the new version
2. Commit: `chore(release): bump version to X.Y.Z`
3. Create an annotated tag `vX.Y.Z`
4. Push the commit and tag to origin

If the user wants to tag without pushing (e.g., to review first), add `--no-push`:

```bash
bash scripts/release.sh <patch|minor|major> --confirm --no-push
```

### 5. Post-Release Verification

After the script completes, confirm the tag exists on the remote:

```bash
git ls-remote --tags origin | grep "vX.Y.Z"
```

Inform the user how consumers receive the update:

- Consumers on `ref: trunk` get it automatically on next `apm deps update`
- Consumers pinned to a tag must update their `apm.yml` to `ref: vX.Y.Z`

### Exit Codes

The script uses distinct exit codes — use these to decide the next action:


| Code | Meaning                                                               |
| ---- | --------------------------------------------------------------------- |
| `0`  | Success                                                               |
| `1`  | Usage error or unexpected failure                                     |
| `2`  | Pre-flight check failed (dirty tree, wrong branch, missing `apm.yml`) |
| `3`  | Tag already exists (duplicate release blocked)                        |


If exit code is `3`, inform the user that this version is already tagged and suggest incrementing to the next version instead.

## Guardrails

- **Never run without a dry run first.** Always preview the release plan and get user confirmation before executing.
- **Always pass `--confirm` when executing.** The agent cannot respond to interactive prompts. Omitting `--confirm` will hang the session.
- **Never tag from a feature branch.** Releases come from `trunk` or `main` only. If the user insists on tagging from another branch, warn them explicitly and require double confirmation.
- **Never re-tag an existing version.** If the tag already exists (exit code `3`), do not bypass it. Increment to a new version instead.
- **Never force-push tags.** If a tag needs correction, create a new version. Deleting and re-creating tags breaks consumers who already resolved the old tag.
- **Always verify the push succeeded.** After execution, confirm the tag is visible on the remote before reporting success.

