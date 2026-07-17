#!/usr/bin/env bash
# Verify Cursor commands do not duplicate skills or cross scopes.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$PROJECT_ROOT/.apm/skills"

failures=0
warn()  { printf "\033[1;33m⚠ %s\033[0m\n" "$1"; }
ok()    { printf "\033[1;32m✓ %s\033[0m\n" "$1"; }
bad()   { printf "\033[1;31m✗ %s\033[0m\n" "$1"; failures=$((failures + 1)); }

check_scope() {
  local label="$1"
  local commands_dir="$2"
  local skills_dir="$3"

  [[ -d "$commands_dir" ]] || { ok "$label: no commands dir"; return 0; }
  [[ -d "$skills_dir" ]] || { ok "$label: no skills dir"; return 0; }

  local cmd skill
  for cmd in "$commands_dir"/*.md; do
    [[ -f "$cmd" ]] || continue
    skill="$(basename "$cmd" .md)"
    if [[ -f "$SKILLS_DIR/${skill}/SKILL.md" ]] || [[ -f "$skills_dir/${skill}/SKILL.md" ]]; then
      bad "$label: command '$skill' duplicates skill (remove $commands_dir/${skill}.md)"
    fi
  done

  if [[ $failures -eq 0 ]]; then
    local count
    count=$(find "$commands_dir" -maxdepth 1 -name '*.md' | wc -l | tr -d ' ')
    ok "$label: $count command(s), no skill collisions"
  fi
}

check_scope "Cursor global" "$HOME/.cursor/commands" "$HOME/.agents/skills"
check_scope "Cursor project" "$PROJECT_ROOT/.cursor/commands" "$PROJECT_ROOT/.agents/skills"
check_scope "Claude global" "$HOME/.claude/commands" "$HOME/.agents/skills"

if [[ -d "$HOME/.cursor/commands" && -d "$PROJECT_ROOT/.cursor/commands" ]]; then
  overlap=$(comm -12 \
    <(find "$HOME/.cursor/commands" -maxdepth 1 -name '*.md' -exec basename {} .md \; | sort) \
    <(find "$PROJECT_ROOT/.cursor/commands" -maxdepth 1 -name '*.md' -exec basename {} .md \; | sort) \
    | wc -l | tr -d ' ')
  if [[ "$overlap" -gt 0 ]]; then
    warn "Global and project share $overlap command name(s) — may appear twice in palette when this repo is open"
    comm -12 \
      <(find "$HOME/.cursor/commands" -maxdepth 1 -name '*.md' -exec basename {} .md \; | sort) \
      <(find "$PROJECT_ROOT/.cursor/commands" -maxdepth 1 -name '*.md' -exec basename {} .md \; | sort) \
      | sed 's/^/    /'
  else
    ok "No global/project command name overlap"
  fi
fi

# Expected skill-backed prompts — must NOT have command files in either scope
for name in triage release-evidence; do
  for dir in "$HOME/.cursor/commands" "$PROJECT_ROOT/.cursor/commands"; do
    [[ -f "$dir/${name}.md" ]] && bad "Stale command still present: $dir/${name}.md (use skill only)"
  done
done

if [[ $failures -gt 0 ]]; then
  echo ""
  bad "$failures duplicate issue(s) found. Run: apm run postinstall (and APM_GLOBAL=1 for global)"
  exit 1
fi

ok "All command duplicate checks passed"
exit 0
