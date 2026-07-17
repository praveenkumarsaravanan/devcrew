#!/usr/bin/env bash
# Fetch HL7 AI-ready FHIR bundles (ai.zip + llms.txt) for LLM-assisted IG development.
# See: https://blog.hl7.org/embracing-ai-as-a-force-multiplier-for-health-data-standards
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUNDLE_ROOT="$PROJECT_ROOT/.fhir/ai-bundles"

info()  { printf "\033[1;34m▸ %s\033[0m\n" "$1"; }
ok()    { printf "\033[1;32m✓ %s\033[0m\n" "$1"; }
warn()  { printf "\033[1;33m⚠ %s\033[0m\n" "$1"; }
fail()  { printf "\033[1;31m✗ %s\033[0m\n" "$1"; exit 1; }

usage() {
  cat <<'USAGE'
Usage: bash scripts/fhir-ai-bundle-setup.sh [preset|base-url] [folder-name]

Fetch HL7 LLM-ready FHIR Implementation Guide bundles (ai.zip and llms.txt).

Presets:
  us-core    US Core IG — https://hl7.org/fhir/us/core/

Or pass a downloads base URL (directory containing ai.zip), e.g.:
  bash scripts/fhir-ai-bundle-setup.sh https://hl7.org/fhir/us/core/ us-core

Output: .fhir/ai-bundles/<folder-name>/{ai.zip, llms.txt, markdown/}

USAGE
  exit 0
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && usage

PRESET="${1:-us-core}"
FOLDER="${2:-}"

case "$PRESET" in
  us-core)
    BASE_URL="https://hl7.org/fhir/us/core"
    FOLDER="${FOLDER:-us-core}"
    ;;
  http://*|https://*)
    BASE_URL="${PRESET%/}"
    FOLDER="${FOLDER:-$(basename "$BASE_URL")}"
    ;;
  *)
    fail "Unknown preset '$PRESET'. Use us-core or pass a full https:// base URL."
    ;;
esac

TARGET="$BUNDLE_ROOT/$FOLDER"
mkdir -p "$TARGET/markdown"

info "Fetching HL7 AI bundle for: $FOLDER"
info "Base URL: $BASE_URL"

download() {
  local url="$1"
  local dest="$2"
  if curl -fsSL --retry 3 --connect-timeout 30 "$url" -o "$dest"; then
    ok "Downloaded $(basename "$dest")"
    return 0
  fi
  return 1
}

AI_ZIP="$TARGET/ai.zip"
if download "$BASE_URL/ai.zip" "$AI_ZIP"; then
  if command -v unzip &>/dev/null; then
    unzip -qo "$AI_ZIP" -d "$TARGET/markdown" && ok "Extracted markdown/"
    rm -f "$AI_ZIP" && ok "Removed ai.zip (use markdown/ + llms.txt; re-run this script to refresh)"
  else
    warn "unzip not found — ai.zip kept at $AI_ZIP but not extracted"
  fi
else
  warn "ai.zip not available at $BASE_URL/ai.zip (IG may not publish LLM-Ready View yet)"
fi

if download "$BASE_URL/llms.txt" "$TARGET/llms.txt"; then
  :
else
  warn "llms.txt not available — check the IG downloads page for LLM-Ready View"
fi

# Workspace gitignore hint
GITIGNORE="$PROJECT_ROOT/.fhir/.gitignore"
if [[ ! -f "$GITIGNORE" ]]; then
  mkdir -p "$(dirname "$GITIGNORE")"
  cat > "$GITIGNORE" <<'EOF'
# HL7 AI bundles can be large — regenerate with: apm run fhir-ai-bundle-setup
ai-bundles/*/markdown/
ai-bundles/*/*.zip
EOF
  ok "Created .fhir/.gitignore"
fi

echo ""
ok "FHIR AI bundle workspace: $TARGET"
echo "  Read llms.txt first, then open only needed files under markdown/"
echo "  Validate implementations against the IG NPM package (package.tgz), not Markdown alone."
echo "  Re-run this script only when you want to refresh the bundle from HL7."
echo "  User guide: docs/fhir-health-interop.md"
echo "  Technical reference: .apm/skills/fhir-health-interop/references/hl7-ai-packages.md"
