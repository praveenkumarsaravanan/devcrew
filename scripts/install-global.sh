#!/usr/bin/env bash
# Install the local DevCrew package globally: compile, deploy all IDE targets, post-install.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGETS="${DEVCREW_TARGETS:-cursor,claude,codex}"

info()  { printf "\033[1;34m▸ %s\033[0m\n" "$1"; }
ok()    { printf "\033[1;32m✓ %s\033[0m\n" "$1"; }
warn()  { printf "\033[1;33m⚠ %s\033[0m\n" "$1"; }
fail()  { printf "\033[1;31m✗ %s\033[0m\n" "$1"; exit 1; }

if ! command -v apm &>/dev/null; then
  fail "APM not found. Install with: brew tap microsoft/apm && brew install apm"
fi

cd "$PROJECT_ROOT"

info "Compiling instructions for all apm.yml targets..."
apm compile

info "Deploying full local package (project scope, targets: $TARGETS)..."
apm install --target "$TARGETS" --force

info "Deploying to global user scope (targets: $TARGETS)..."
apm install -g --target "$TARGETS" --force

info "Syncing newest skills from local build to ~/.agents/skills/..."
mkdir -p "$HOME/.agents/skills"
rsync -a --delete "$PROJECT_ROOT/.agents/skills/" "$HOME/.agents/skills/"

info "Deploying global Cursor prompts and Codex hooks..."
export APM_GLOBAL=1
bash "$SCRIPT_DIR/post-install.sh" --global

info "Verifying global deployment..."
checks=0
failures=0

check() {
  local label="$1"
  shift
  if "$@" &>/dev/null; then
    ok "$label"
    checks=$((checks + 1))
  else
    warn "Missing: $label"
    failures=$((failures + 1))
  fi
}

check "Cursor commands" test -d "$HOME/.cursor/commands"
check "Cursor hooks" test -f "$HOME/.cursor/hooks.json"
check "Claude agents dir" test -d "$HOME/.claude/agents" -o -d "$HOME/.claude"
check "Codex hooks" test -f "$HOME/.codex/hooks.json"
check "Codex hook script" test -x "$HOME/.codex/hooks/security-pre-tool.sh"
check "Shared skills (triage)" test -f "$HOME/.agents/skills/triage/SKILL.md"
check "Triage skill (no command dup)" test ! -f "$HOME/.cursor/commands/triage.md"
check "Release-evidence skill (no command dup)" test ! -f "$HOME/.cursor/commands/release-evidence.md"

info "Running duplicate command audit..."
bash "$SCRIPT_DIR/verify-commands.sh" || failures=$((failures + 1))

echo ""
if [[ $failures -eq 0 ]]; then
  ok "Global DevCrew install complete — all checks passed."
else
  warn "Global install finished with $failures check(s) failed ($checks passed)."
fi

echo ""
echo "  Skills/agents:  ~/.agents/skills/, ~/.cursor/agents/, ~/.claude/"
echo "  Commands:       ~/.cursor/commands/"
echo "  Cursor hooks:   ~/.cursor/hooks.json"
echo "  Codex hooks:    ~/.codex/hooks.json"
echo ""
echo "  Triage workspace:  apm run triage-setup [dir]  (per-project, not global)"
echo "  Refresh global:    apm run install-global"
echo "  After release:     apm install -g --https github.com/praveenkumarsaravanan/devcrew --update"
