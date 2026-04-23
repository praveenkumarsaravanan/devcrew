#!/usr/bin/env bash
set -euo pipefail

# ── Exit codes ────────────────────────────────────────────────────────────────
# 0  Success
# 1  General / usage error
# 2  Pre-flight check failed (dirty tree, wrong branch, missing apm.yml)
# 3  Tag already exists (duplicate release blocked)

# ── Helpers ───────────────────────────────────────────────────────────────────

info()  { printf "\033[1;34m▸ %s\033[0m\n" "$1" >&2; }
ok()    { printf "\033[1;32m✓ %s\033[0m\n" "$1" >&2; }
warn()  { printf "\033[1;33m⚠ %s\033[0m\n" "$1" >&2; }
fail()  { printf "\033[1;31m✗ %s\033[0m\n" "$1" >&2; exit "${2:-1}"; }

usage() {
  cat <<'USAGE'
Usage: bash scripts/release.sh [OPTIONS] [patch|minor|major]

Reads the current version from apm.yml, auto-increments it, updates the file,
commits, tags, pushes, and creates a GitHub release.

Arguments:
  patch             Increment patch version: 1.0.0 → 1.0.1 (default)
  minor             Increment minor version: 1.0.0 → 1.1.0
  major             Increment major version: 1.0.0 → 2.0.0

Options:
  -h, --help        Show this help message
  --dry-run         Show the release plan without making changes
  --confirm         Skip interactive prompts (required for agent/CI use)
  --no-push         Create the tag locally but do not push to origin
  --no-release      Push the tag but skip GitHub release creation
  --json            Output the release summary as JSON to stdout
  --ticket TICKET   JIRA ticket ID to include in commit message (e.g., JIR-39314)

Exit codes:
  0  Success
  1  Usage error or unexpected failure
  2  Pre-flight check failed (dirty tree, wrong branch, missing apm.yml)
  3  Tag already exists

Examples:
  bash scripts/release.sh patch                   # Interactive patch release
  bash scripts/release.sh minor --dry-run          # Preview a minor bump
  bash scripts/release.sh major --confirm          # Non-interactive major release
  bash scripts/release.sh patch --confirm --json   # Agent-friendly: no prompts, JSON output
  bash scripts/release.sh minor --ticket JIR-123   # Include JIRA ticket in commit
USAGE
  exit 0
}

# ── Parse arguments ───────────────────────────────────────────────────────────

DRY_RUN=false
CONFIRM=false
NO_PUSH=false
NO_RELEASE=false
JSON_OUTPUT=false
INCREMENT="patch"
TICKET=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)    usage ;;
    --dry-run)    DRY_RUN=true ;;
    --confirm)    CONFIRM=true ;;
    --no-push)    NO_PUSH=true ;;
    --no-release) NO_RELEASE=true ;;
    --json)       JSON_OUTPUT=true ;;
    --ticket)
      shift
      [[ -z "${1:-}" ]] && fail "--ticket requires a JIRA ticket ID (e.g., JIR-39314)" 1
      TICKET="$1"
      ;;
    patch|minor|major) INCREMENT="$1" ;;
    *) fail "Unknown argument: $1. Run with --help for usage." 1 ;;
  esac
  shift
done

# ── Pre-flight checks ────────────────────────────────────────────────────────

APM_YML="apm.yml"

[[ -f "$APM_YML" ]] || fail "apm.yml not found in $(pwd). Run this from the repo root." 2

if ! git diff --quiet HEAD 2>/dev/null; then
  fail "Working tree is dirty. Commit or stash changes before releasing." 2
fi

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$CURRENT_BRANCH" != "trunk" && "$CURRENT_BRANCH" != "main" ]]; then
  fail "Releases must be tagged from trunk or main. Currently on: $CURRENT_BRANCH" 2
fi

git fetch --tags --quiet
git fetch origin "$CURRENT_BRANCH" --quiet

LOCAL_SHA=$(git rev-parse HEAD)
REMOTE_SHA=$(git rev-parse "origin/$CURRENT_BRANCH" 2>/dev/null || echo "")

if [[ -n "$REMOTE_SHA" ]]; then
  if [[ "$LOCAL_SHA" != "$REMOTE_SHA" ]]; then
    AHEAD=$(git rev-list "origin/$CURRENT_BRANCH..HEAD" --count 2>/dev/null || echo 0)
    BEHIND=$(git rev-list "HEAD..origin/$CURRENT_BRANCH" --count 2>/dev/null || echo 0)
    if [[ "$BEHIND" -gt 0 ]]; then
      fail "$CURRENT_BRANCH is $BEHIND commit(s) behind origin/$CURRENT_BRANCH. Pull first: git pull origin $CURRENT_BRANCH" 2
    fi
    if [[ "$AHEAD" -gt 0 ]]; then
      fail "$CURRENT_BRANCH is $AHEAD commit(s) ahead of origin/$CURRENT_BRANCH. Push first: git push origin $CURRENT_BRANCH" 2
    fi
  fi
fi

UNMERGED_BRANCHES=""
for branch in $(git branch --no-merged HEAD --format='%(refname:short)' 2>/dev/null); do
  UNMERGED_COUNT=$(git rev-list "HEAD..$branch" --count 2>/dev/null || echo 0)
  if [[ "$UNMERGED_COUNT" -gt 0 ]]; then
    UNMERGED_BRANCHES="${UNMERGED_BRANCHES}    ${branch} ($UNMERGED_COUNT unmerged commit(s))\n"
  fi
done

if [[ -n "$UNMERGED_BRANCHES" ]]; then
  warn "The following local branches have commits NOT merged into $CURRENT_BRANCH:"
  printf "$UNMERGED_BRANCHES" >&2
  if [[ "$CONFIRM" == true ]]; then
    warn "Proceeding despite unmerged branches (--confirm). Verify this is intentional."
  else
    printf "\033[1;33m? Continue release despite unmerged branches? [y/N] \033[0m" >&2
    read -r UNMERGED_RESPONSE
    if [[ "$UNMERGED_RESPONSE" != "y" && "$UNMERGED_RESPONSE" != "Y" ]]; then
      info "Aborted. Merge or delete unmerged branches first."
      exit 2
    fi
  fi
fi

# ── Read current version ──────────────────────────────────────────────────────

CURRENT_VERSION=$(grep -E '^version:' "$APM_YML" | head -1 | sed 's/version:[[:space:]]*"\{0,1\}\([^"]*\)"\{0,1\}/\1/')

if [[ -z "$CURRENT_VERSION" ]]; then
  fail "Could not read version from $APM_YML" 2
fi

IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

if [[ -z "$MAJOR" || -z "$MINOR" || -z "$PATCH" ]]; then
  fail "Version '$CURRENT_VERSION' is not valid semver (expected X.Y.Z)" 2
fi

info "Current version: $CURRENT_VERSION"

# ── Check if current version tag already exists ──────────────────────────────

CURRENT_TAG="v${CURRENT_VERSION}"
if git tag -l "$CURRENT_TAG" | grep -q "$CURRENT_TAG"; then
  ok "Tag $CURRENT_TAG already exists (current version is released)"
else
  warn "Tag $CURRENT_TAG does not exist yet — current version is unreleased"
fi

# ── Compute next version ─────────────────────────────────────────────────────

case "$INCREMENT" in
  patch) NEXT_VERSION="$MAJOR.$MINOR.$((PATCH + 1))" ;;
  minor) NEXT_VERSION="$MAJOR.$((MINOR + 1)).0" ;;
  major) NEXT_VERSION="$((MAJOR + 1)).0.0" ;;
esac

NEXT_TAG="v${NEXT_VERSION}"

# ── Block if the target tag already exists ────────────────────────────────────

if git tag -l "$NEXT_TAG" | grep -q "$NEXT_TAG"; then
  fail "Tag $NEXT_TAG already exists. Cannot re-tag an existing release. Increment to a new version instead." 3
fi

# ── Build changelog ──────────────────────────────────────────────────────────

PREV_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [[ -n "$PREV_TAG" ]]; then
  CHANGELOG=$(git log "${PREV_TAG}..HEAD" --pretty=format:"- %s" --no-merges)
  CHANGELOG_RANGE="${PREV_TAG}..HEAD"
else
  CHANGELOG=$(git log --pretty=format:"- %s" --no-merges)
  CHANGELOG_RANGE="(all commits)"
fi

if [[ -z "$CHANGELOG" ]]; then
  CHANGELOG="- No changes since ${PREV_TAG:-initial commit}"
fi

# ── Show summary ──────────────────────────────────────────────────────────────

if [[ "$JSON_OUTPUT" == true ]]; then
  CHANGELOG_JSON=$(echo "$CHANGELOG" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read().strip()))" 2>/dev/null || echo "\"$CHANGELOG\"")
  cat <<JSON
{"increment":"$INCREMENT","current_version":"$CURRENT_VERSION","next_version":"$NEXT_VERSION","tag":"$NEXT_TAG","branch":"$CURRENT_BRANCH","dry_run":$DRY_RUN,"changes":$CHANGELOG_JSON}
JSON
else
  echo "" >&2
  echo "  Release plan:" >&2
  echo "  ─────────────────────────────────────────" >&2
  echo "  Increment:       $INCREMENT" >&2
  echo "  Current version: $CURRENT_VERSION" >&2
  echo "  Next version:    $NEXT_VERSION" >&2
  echo "  Tag:             $NEXT_TAG" >&2
  echo "  Branch:          $CURRENT_BRANCH" >&2
  echo "  ─────────────────────────────────────────" >&2
  echo "" >&2
  echo "  Changes since ${PREV_TAG:-beginning}:" >&2
  echo "$CHANGELOG" | while IFS= read -r line; do
    echo "    $line" >&2
  done
  echo "" >&2
fi

if [[ "$DRY_RUN" == true ]]; then
  info "[dry-run] Would update apm.yml, commit, tag $NEXT_TAG (with changelog), and push."
  exit 0
fi

# ── Confirm (interactive only) ────────────────────────────────────────────────

if [[ "$CONFIRM" != true ]]; then
  printf "\033[1;33m? Proceed with release %s? [y/N] \033[0m" "$NEXT_VERSION" >&2
  read -r RESPONSE
  if [[ "$RESPONSE" != "y" && "$RESPONSE" != "Y" ]]; then
    info "Aborted."
    exit 0
  fi
fi

# ── Update apm.yml ────────────────────────────────────────────────────────────

if [[ "$(uname)" == "Darwin" ]]; then
  sed -i '' "s/^version:.*$/version: \"${NEXT_VERSION}\"/" "$APM_YML"
else
  sed -i "s/^version:.*$/version: \"${NEXT_VERSION}\"/" "$APM_YML"
fi

UPDATED_VERSION=$(grep -E '^version:' "$APM_YML" | head -1 | sed 's/version:[[:space:]]*"\{0,1\}\([^"]*\)"\{0,1\}/\1/')
if [[ "$UPDATED_VERSION" != "$NEXT_VERSION" ]]; then
  fail "Failed to update version in $APM_YML. Expected $NEXT_VERSION, got $UPDATED_VERSION"
fi

ok "Updated apm.yml → $NEXT_VERSION"

# ── Commit ────────────────────────────────────────────────────────────────────

git add "$APM_YML"
if [[ -n "$TICKET" ]]; then
  git commit -m "chore(release): ${TICKET}, bump version to ${NEXT_VERSION}"
else
  git commit -m "chore(release): bump version to ${NEXT_VERSION}"
fi
ok "Committed version bump"

# ── Tag ───────────────────────────────────────────────────────────────────────

TAG_MESSAGE="Release ${NEXT_VERSION}

Changes since ${PREV_TAG:-beginning}:

${CHANGELOG}"

git tag -a "$NEXT_TAG" -m "$TAG_MESSAGE"
ok "Created tag $NEXT_TAG"

# ── Push ──────────────────────────────────────────────────────────────────────

if [[ "$NO_PUSH" == true ]]; then
  warn "Tag created locally (--no-push). Push manually:"
  echo "  git push origin $CURRENT_BRANCH && git push origin $NEXT_TAG" >&2
  exit 0
fi

if [[ "$CONFIRM" != true ]]; then
  printf "\033[1;33m? Push commit and tag to origin? [y/N] \033[0m" >&2
  read -r PUSH_RESPONSE
  if [[ "$PUSH_RESPONSE" != "y" && "$PUSH_RESPONSE" != "Y" ]]; then
    warn "Tag created locally but NOT pushed. Run manually:"
    echo "  git push origin $CURRENT_BRANCH && git push origin $NEXT_TAG" >&2
    exit 0
  fi
fi

git push origin "$CURRENT_BRANCH"
git push origin "$NEXT_TAG"
ok "Pushed $CURRENT_BRANCH and $NEXT_TAG to origin"

# ── GitHub Release ────────────────────────────────────────────────────────────

if [[ "$NO_RELEASE" == true ]]; then
  warn "Skipping GitHub release (--no-release). Create manually:"
  echo "  gh release create $NEXT_TAG --title \"$NEXT_TAG\" --notes \"<changelog>\"" >&2
else
  if command -v gh &>/dev/null; then
    RELEASE_BODY="## Changes since ${PREV_TAG:-beginning}

${CHANGELOG}"

    if gh release create "$NEXT_TAG" \
        --title "$NEXT_TAG" \
        --notes "$RELEASE_BODY" \
        --target "$CURRENT_BRANCH" 2>/dev/null; then
      ok "Created GitHub release for $NEXT_TAG"
    else
      warn "Failed to create GitHub release. Create manually:"
      echo "  gh release create $NEXT_TAG --title \"$NEXT_TAG\" --notes \"<changelog>\"" >&2
    fi
  else
    warn "gh CLI not found — skipping GitHub release. Install gh and run:"
    echo "  gh release create $NEXT_TAG --title \"$NEXT_TAG\" --notes \"<changelog>\"" >&2
  fi
fi

echo "" >&2
ok "Release $NEXT_VERSION ($NEXT_TAG) complete!"
echo "" >&2
echo "  Consumers tracking 'ref: $CURRENT_BRANCH' will get this on next 'apm deps update'." >&2
echo "  Consumers pinned to a tag should update their apm.yml to: ref: $NEXT_TAG" >&2
