#!/usr/bin/env bash
# Deploy Codex-native hooks (PascalCase events, command handlers).
# APM copies Cursor-format prompt hooks verbatim; Codex requires command hooks.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_HOOK="$SCRIPT_DIR/codex-hooks/security-pre-tool.sh"

is_global() {
  [[ "${APM_GLOBAL:-}" == "1" ]] || [[ "${1:-}" == "--global" ]]
}

if is_global "$@"; then
  CODEX_DIR="$HOME/.codex"
  SCOPE="user"
else
  CODEX_DIR="$(cd "$SCRIPT_DIR/.." && pwd)/.codex"
  SCOPE="project"
fi

HOOKS_JSON="$CODEX_DIR/hooks.json"
HOOKS_BIN_DIR="$CODEX_DIR/hooks"
DEPLOYED_HOOK="$HOOKS_BIN_DIR/security-pre-tool.sh"

mkdir -p "$HOOKS_BIN_DIR"
chmod +x "$SOURCE_HOOK"
cp "$SOURCE_HOOK" "$DEPLOYED_HOOK"
chmod +x "$DEPLOYED_HOOK"

# Path relative to hooks.json (Codex resolves from hooks.json location).
HOOK_COMMAND="hooks/security-pre-tool.sh"

cat > "$HOOKS_JSON" <<EOF
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "$HOOK_COMMAND",
            "statusMessage": "DevCrew: checking command for secret writes",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
EOF

echo "[+] Deployed Codex hooks -> $HOOKS_JSON ($SCOPE scope)"
echo "[i] Lint/eval afterFileEdit hooks remain Cursor-only; Codex file-edit hooks are not available yet."
