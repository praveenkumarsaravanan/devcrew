#!/usr/bin/env bash
set -euo pipefail

# Bootstraps an empty .memory.md with domain section headers and the
# .memory/ directory for overflow and archives.
# Runs during `apm install` (via scripts.setup) or manually.
# The AI agent appends learnings after each team-workflow run.

MEMORY_FILE=".memory.md"
MEMORY_DIR=".memory"
ARCHIVE_DIR=".memory/archive"

info()  { printf "\033[1;34m▸ %s\033[0m\n" "$1"; }
ok()    { printf "\033[1;32m✓ %s\033[0m\n" "$1"; }

# ── Create .memory/ directory structure ──────────────────────────────────────

if [[ ! -d "$MEMORY_DIR" ]]; then
  mkdir -p "$ARCHIVE_DIR"
  ok "Created $MEMORY_DIR/ directory (overflow + archive)"
else
  # Ensure archive subdirectory exists even if .memory/ was created manually
  [[ -d "$ARCHIVE_DIR" ]] || mkdir -p "$ARCHIVE_DIR"
fi

# ── Add .memory/ to .gitignore exclusion (ensure it's tracked) ──────────────

# .memory/ should be committed, but some .gitignore templates ignore dotfiles.
# If .gitignore exists and has a blanket dotfile ignore, add an exception.
if [[ -f ".gitignore" ]]; then
  if grep -qE '^\.\*' .gitignore 2>/dev/null && ! grep -q '!\.memory' .gitignore 2>/dev/null; then
    echo "" >> .gitignore
    echo "# DevCrew memory files (committed — shared team knowledge)" >> .gitignore
    echo "!.memory.md" >> .gitignore
    echo "!.memory/" >> .gitignore
    info "Added .memory.md and .memory/ exceptions to .gitignore"
  fi
fi

# ── Skip .memory.md if already exists ────────────────────────────────────────

if [[ -f "$MEMORY_FILE" ]]; then
  ok "$MEMORY_FILE already exists — skipping"
  exit 0
fi

# ── Write empty template ─────────────────────────────────────────────────────

cat > "$MEMORY_FILE" <<'EOF'
# Project Memory

Accumulated learnings across development sessions. Entries are appended
automatically after each `team-workflow` completion and can be added
manually at any time. Committed to version control so the entire team
(and future AI sessions) benefit from past experience.

> **Size budget:** This file is capped at ~150 lines. When a domain section
> grows beyond 20 entries, older entries rotate to `.memory/<domain>.md`.
> Entries older than 6 months archive to `.memory/archive/<quarter>.md`.

## Architecture Decisions

<!-- System-level structural choices and trade-offs -->

## Auth & Security

<!-- Authentication, authorization, secrets management -->

## Data Handling

<!-- Database design, migrations, caching strategies -->

## Performance

<!-- Optimization patterns, profiling results -->

## Testing

<!-- Test strategy insights, coverage gaps, testing patterns -->

## Deployment

<!-- CI/CD learnings, environment configuration, rollback procedures -->

## API Design

<!-- Endpoint conventions, versioning decisions -->

## UI Patterns

<!-- Component patterns, accessibility learnings, state management -->

## General

<!-- Cross-cutting learnings that don't fit a specific domain -->
EOF

ok "Created $MEMORY_FILE with domain section headers"
ok "Created $MEMORY_DIR/ for overflow and $ARCHIVE_DIR/ for quarterly archives"
info "The AI agent will append learnings here after each team-workflow run."
info "When this file exceeds ~150 lines, older entries rotate to .memory/<domain>.md automatically."
