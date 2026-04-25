#!/usr/bin/env bash
# Workaround: APM does not deploy .prompt.md files to .cursor/commands/.
# This script copies them manually after `apm install`.
# Track: https://github.com/microsoft/apm/issues — Cursor prompt deployment
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SOURCE_DIR="$PROJECT_ROOT/.apm/prompts"
USER_CURSOR_DIR="$HOME/.cursor"
PROJECT_CURSOR_DIR="$PROJECT_ROOT/.cursor"

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "[i] No .apm/prompts/ directory found — skipping."
  exit 0
fi

# Determine target: user-level (~/.cursor) for global installs,
# project-level (.cursor/) otherwise.
if [[ "${APM_GLOBAL:-}" == "1" ]] || [[ "${1:-}" == "--global" ]]; then
  CURSOR_BASE="$USER_CURSOR_DIR"
  SCOPE="user"
elif [[ -d "$PROJECT_CURSOR_DIR" ]]; then
  CURSOR_BASE="$PROJECT_CURSOR_DIR"
  SCOPE="project"
elif [[ -d "$USER_CURSOR_DIR" ]]; then
  CURSOR_BASE="$USER_CURSOR_DIR"
  SCOPE="user"
else
  echo "[i] No .cursor/ directory found at project or user level — skipping."
  exit 0
fi

TARGET_DIR="$CURSOR_BASE/commands"
mkdir -p "$TARGET_DIR"

count=0
for src in "$SOURCE_DIR"/*.prompt.md; do
  [[ -f "$src" ]] || continue
  filename="$(basename "$src" .prompt.md).md"
  cp "$src" "$TARGET_DIR/$filename"
  count=$((count + 1))
done

if [[ $count -gt 0 ]]; then
  echo "[+] Deployed $count prompt(s) -> $TARGET_DIR/ ($SCOPE scope)"
else
  echo "[i] No .prompt.md files found in $SOURCE_DIR"
fi
