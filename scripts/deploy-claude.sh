#!/usr/bin/env bash
set -euo pipefail

# Workaround for microsoft/apm#751 — deploys .apm/ primitives to .claude/
# directories until APM registers claude as a first-class runtime.
# Once fixed, use: apm install --target claude

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APM_DIR="$PROJECT_ROOT/.apm"
CLAUDE_DIR="$PROJECT_ROOT/.claude"

info()  { printf "\033[1;34m▸ %s\033[0m\n" "$1"; }
ok()    { printf "\033[1;32m✓ %s\033[0m\n" "$1"; }
warn()  { printf "\033[1;33m⚠ %s\033[0m\n" "$1"; }

copied=0

if [[ ! -d "$APM_DIR" ]]; then
  echo "No .apm/ directory found at $PROJECT_ROOT — nothing to deploy." >&2
  exit 1
fi

# ── Agents: .apm/agents/*.agent.md → .claude/agents/*.md ─────────────────────

info "Deploying agents..."
mkdir -p "$CLAUDE_DIR/agents"
for src in "$APM_DIR"/agents/*.agent.md; do
  [[ -f "$src" ]] || continue
  base="$(basename "$src" .agent.md).md"
  cp "$src" "$CLAUDE_DIR/agents/$base"
  ok "  agents/$base"
  ((copied++)) || true
done

# ── Skills: .apm/skills/*/ → .claude/skills/*/ ───────────────────────────────

info "Deploying skills..."
mkdir -p "$CLAUDE_DIR/skills"
for src in "$APM_DIR"/skills/*/; do
  [[ -d "$src" ]] || continue
  name="$(basename "$src")"
  rm -rf "$CLAUDE_DIR/skills/$name"
  cp -R "$src" "$CLAUDE_DIR/skills/$name"
  ok "  skills/$name/"
  ((copied++)) || true
done

# ── Instructions: .apm/instructions/*.instructions.md → .claude/rules/*.md ───

info "Deploying instructions as rules..."
mkdir -p "$CLAUDE_DIR/rules"
for src in "$APM_DIR"/instructions/*.instructions.md; do
  [[ -f "$src" ]] || continue
  base="$(basename "$src" .instructions.md).md"
  cp "$src" "$CLAUDE_DIR/rules/$base"
  ok "  rules/$base"
  ((copied++)) || true
done

# ── Prompts: .apm/prompts/*.prompt.md → .claude/commands/*.md ─────────────────

info "Deploying prompts as commands..."
mkdir -p "$CLAUDE_DIR/commands"
for src in "$APM_DIR"/prompts/*.prompt.md; do
  [[ -f "$src" ]] || continue
  base="$(basename "$src" .prompt.md).md"
  cp "$src" "$CLAUDE_DIR/commands/$base"
  ok "  commands/$base"
  ((copied++)) || true
done

# ── CLAUDE.md: compile instructions via APM if available ──────────────────────

if command -v apm &>/dev/null; then
  info "Generating CLAUDE.md via apm compile..."
  (cd "$PROJECT_ROOT" && apm compile --target claude) >/dev/null 2>&1 && ok "CLAUDE.md" || warn "apm compile --target claude failed — skipping CLAUDE.md generation"
else
  warn "APM CLI not found — skipping CLAUDE.md generation"
fi

# ── Summary ───────────────────────────────────────────────────────────────────

echo ""
if [[ $copied -gt 0 ]]; then
  ok "Deployed $copied artifacts to .claude/"
else
  warn "No artifacts found in .apm/ to deploy"
fi
info "Workaround for microsoft/apm#751. Once fixed, use: apm install --target claude"
