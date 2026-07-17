#!/usr/bin/env bash
# Post-install workarounds after `apm install`:
# - Copy .prompt.md files to .cursor/commands/ (APM gap)
# - Deploy Codex-native command hooks (APM deploys Cursor prompt hooks to Codex)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SOURCE_DIR="$PROJECT_ROOT/.apm/prompts"
USER_CURSOR_DIR="$HOME/.cursor"
PROJECT_CURSOR_DIR="$PROJECT_ROOT/.cursor"

is_global() {
  [[ "${APM_GLOBAL:-}" == "1" ]] || [[ "${1:-}" == "--global" ]]
}

# ── Cursor prompts ───────────────────────────────────────────────────────────

if [[ -d "$SOURCE_DIR" ]]; then
  if is_global "$@"; then
    CURSOR_BASE="$USER_CURSOR_DIR"
    SCOPE="user"
  elif [[ -d "$PROJECT_CURSOR_DIR" ]]; then
    CURSOR_BASE="$PROJECT_CURSOR_DIR"
    SCOPE="project"
  else
    CURSOR_BASE=""
    SCOPE=""
  fi

  if [[ -n "$CURSOR_BASE" ]]; then
    TARGET_DIR="$CURSOR_BASE/commands"
    mkdir -p "$TARGET_DIR"

    count=0
    skipped=0
    for src in "$SOURCE_DIR"/*.prompt.md; do
      [[ -f "$src" ]] || continue
      name="$(basename "$src" .prompt.md)"
      filename="${name}.md"

      # Skills with the same name are already slash-invokable via .agents/skills/.
      if [[ -f "$PROJECT_ROOT/.apm/skills/${name}/SKILL.md" ]]; then
        rm -f "$TARGET_DIR/$filename"
        skipped=$((skipped + 1))
        continue
      fi

      # Project scope: skip when global already has this command (avoids palette duplicates).
      if [[ "$SCOPE" == "project" && -f "$USER_CURSOR_DIR/commands/$filename" ]]; then
        rm -f "$TARGET_DIR/$filename"
        skipped=$((skipped + 1))
        continue
      fi

      cp "$src" "$TARGET_DIR/$filename"
      count=$((count + 1))
    done

    if [[ $count -gt 0 ]]; then
      echo "[+] Deployed $count prompt(s) -> $TARGET_DIR/ ($SCOPE scope)"
    elif [[ $skipped -gt 0 ]]; then
      echo "[i] Skipped $skipped prompt(s) in $SCOPE scope (skill collision or already in global commands)"
    else
      echo "[i] No .prompt.md files found in $SOURCE_DIR"
    fi
  elif ! is_global "$@"; then
    echo "[i] No .cursor/ directory in project — skipping project prompts. Use --global for ~/.cursor."
  fi
else
  echo "[i] No .apm/prompts/ directory found — skipping Cursor prompt deploy."
fi

# ── Codex hooks ────────────────────────────────────────────────────────────────

if is_global "$@"; then
  bash "$SCRIPT_DIR/setup-codex-hooks.sh" --global
elif [[ -d "$PROJECT_ROOT/.codex" ]]; then
  bash "$SCRIPT_DIR/setup-codex-hooks.sh"
else
  echo "[i] No project .codex/ directory — skipping project Codex hooks. Use --global for ~/.codex."
fi
