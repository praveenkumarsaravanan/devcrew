#!/usr/bin/env bash
set -euo pipefail

# Scaffolds a self-contained triage workspace for the `triage` skill.
# Run manually: bash scripts/triage-setup.sh [target-dir]
# Idempotent — skips anything that already exists.
#
# Creates (under the target dir, default ./triage-workspace):
#   triage-mirrors/         bare git clones (object cache; gitignored)
#   triage-runs/            per-incident worktrees + cards (gitignored)
#   triage-knowledge-base/
#     incidents/            confirmed root causes (the compounding memory)
#     test-inputs/          symptom-only issue reports
#     service-map.md        which repo owns what
#   RUNBOOK.md pointer, .gitignore

info()  { printf "\033[1;34m▸ %s\033[0m\n" "$1"; }
ok()    { printf "\033[1;32m✓ %s\033[0m\n" "$1"; }
warn()  { printf "\033[1;33m⚠ %s\033[0m\n" "$1"; }

TARGET="${1:-./triage-workspace}"

info "Setting up triage workspace at: $TARGET"

mkdir -p "$TARGET/triage-mirrors" \
         "$TARGET/triage-runs" \
         "$TARGET/triage-knowledge-base/incidents" \
         "$TARGET/triage-knowledge-base/test-inputs"

touch "$TARGET/triage-mirrors/.gitkeep" "$TARGET/triage-runs/.gitkeep"

# ── .gitignore (keep cache/scratch out of git; they're large + proprietary) ──
if [[ ! -f "$TARGET/.gitignore" ]]; then
  cat > "$TARGET/.gitignore" <<'EOF'
triage-mirrors/*
!triage-mirrors/.gitkeep
triage-runs/*
!triage-runs/.gitkeep
.env
*.local
.DS_Store
EOF
  ok "Created .gitignore"
fi

# ── Bitbucket base (optional — enables mirror auto-create) ──────────────────
if [[ ! -f "$TARGET/.triage-config" ]]; then
  DEFAULT_BB=""
  if command -v git >/dev/null 2>&1; then
    DEFAULT_BB=$(git config --get remote.origin.url 2>/dev/null | sed -E 's#(.*[:/])[^/]+\.git#\1#' || echo "")
  fi
  echo ""
  read -rp "  Bitbucket base URL for repos (e.g. git@bitbucket.org:org/) [$DEFAULT_BB]: " BB
  BB="${BB:-$DEFAULT_BB}"
  cat > "$TARGET/.triage-config" <<EOF
# Triage workspace config (sourced by tooling)
BITBUCKET_BASE="$BB"
EOF
  ok "Wrote .triage-config (BITBUCKET_BASE=$BB)"
  warn "Mirrors require VPN/Bitbucket access. Use a READ-ONLY token in your keychain, not a file."
fi

# ── service-map.md ──────────────────────────────────────────────────────────
if [[ ! -f "$TARGET/triage-knowledge-base/service-map.md" ]]; then
  cat > "$TARGET/triage-knowledge-base/service-map.md" <<'EOF'
# Service Map

Hand-grown registry: which repo owns what. Grow it as you triage — don't complete it upfront.
A feature with "import / sync / refresh / process" in its name often lives in a dedicated
service, not the API — enumerate candidates before anchoring on the first match.

| Repo | Type | Responsibility | Signals that point here (log groups, routes, queues, error patterns) |
|------|------|----------------|----------------------------------------------------------------------|
| _add as you triage_ | | | |
EOF
  ok "Created service-map.md"
fi

# ── incident memory template (confirmed causes, with postmortem section) ─────
if [[ ! -f "$TARGET/triage-knowledge-base/incidents/_TEMPLATE.md" ]]; then
  cat > "$TARGET/triage-knowledge-base/incidents/_TEMPLATE.md" <<'EOF'
---
fingerprint: ""        # normalized error signature (strip IDs/timestamps/line numbers). The lookup key.
service: ""
date: ""               # YYYY-MM-DD
ref_triaged: ""        # git ref triaged, e.g. main@a1b2c3d or v4.21.0
fix_commit: ""         # the commit/PR that actually fixed it (human-confirmed)
status: resolved       # resolved | mitigated | wont-fix
hypothesis_was: ""     # correct | partially-correct | wrong
---

# INC-XXXX — <title>

## Symptom
## Root cause (human-confirmed)
## Fix

## Postmortem — why the fix works & what else might break
- **Why this fix resolves the symptom:**
- **Was the triage hypothesis right?** (correct/partial/wrong + why — the method's feedback signal)
- **Sibling failure sites (where else could this break?):**
- **Follow-up actions:**

## Evidence / links
## Notes for next time
EOF
  ok "Created incidents/_TEMPLATE.md"
fi

# ── test-input template (symptom-only) ───────────────────────────────────────
if [[ ! -f "$TARGET/triage-knowledge-base/test-inputs/_TEMPLATE.md" ]]; then
  cat > "$TARGET/triage-knowledge-base/test-inputs/_TEMPLATE.md" <<'EOF'
---
incident_no: ""
title: ""
client: ""
priority: ""
date_received: ""
suspected_service: ""   # a guess until confirmed
attachments: ""         # listed? available? (failure artifact is the highest-value input)
status: unresolved
---

# #<incident_no> — <title>

## Reported symptom
## Triage notes (pre-investigation — signals only, NOT a root cause)
EOF
  ok "Created test-inputs/_TEMPLATE.md"
fi

echo ""
ok "Triage workspace ready at $TARGET"
info "Next: create a mirror once per repo — git clone --mirror <repo-url> $TARGET/triage-mirrors/<repo>.git"
info "Then run the /triage prompt (or activate the 'triage' skill) on an incident."
