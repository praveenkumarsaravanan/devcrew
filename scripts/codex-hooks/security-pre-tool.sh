#!/usr/bin/env bash
# Codex PreToolUse hook: block Bash commands that appear to write secrets to files.
set -euo pipefail

payload="$(cat)"

python3 - <<'PY' "$payload"
import json, re, sys

payload = sys.argv[1]
try:
    data = json.loads(payload)
except json.JSONDecodeError:
    sys.exit(0)

tool_input = data.get("tool_input") or {}
command = ""
if isinstance(tool_input, dict):
    command = str(tool_input.get("command") or "")
elif isinstance(tool_input, str):
    command = tool_input

if not command:
    sys.exit(0)

secret_patterns = [
    r"(?i)(api[_-]?key|secret|token|password|credential)\s*[=:]\s*['\"]?[A-Za-z0-9_\-]{8,}",
    r"(?i)ghp_[A-Za-z0-9]{20,}",
    r"(?i)gho_[A-Za-z0-9]{20,}",
    r"(?i)xox[baprs]-[A-Za-z0-9\-]+",
    r"(?i)AKIA[0-9A-Z]{16}",
    r"(?i)-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----",
]

write_patterns = [
    r">\s*[^\s|&;]+",
    r"\btee\b",
    r"\bcat\s*>>",
]

looks_like_write = any(re.search(p, command) for p in write_patterns)
has_secret = any(re.search(p, command) for p in secret_patterns)

if looks_like_write and has_secret:
    print(json.dumps({
        "decision": "block",
        "reason": "Blocked by DevCrew security-guard: command appears to write secret material to a file."
    }))
    sys.exit(2)

sys.exit(0)
PY
