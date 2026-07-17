#!/usr/bin/env bash
set -euo pipefail

GHE_HOST="${GHE_HOST:-github.com}"
GIT_PROTOCOL="${GIT_PROTOCOL:-ssh}"
REQUIRED_GH_VERSION="2.40.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info()  { printf "\033[1;34m▸ %s\033[0m\n" "$1"; }
ok()    { printf "\033[1;32m✓ %s\033[0m\n" "$1"; }
warn()  { printf "\033[1;33m⚠ %s\033[0m\n" "$1"; }
fail()  { printf "\033[1;31m✗ %s\033[0m\n" "$1"; exit 1; }

version_gte() {
  printf '%s\n%s' "$1" "$2" | sort -V | head -n1 | grep -qx "$2"
}

# ── 1. gh CLI ────────────────────────────────────────────────────────────────

info "Checking gh CLI..."

if ! command -v gh &>/dev/null; then
  info "gh not found — installing via Homebrew..."
  if ! command -v brew &>/dev/null; then
    fail "Homebrew is required to install gh. Install it from https://brew.sh"
  fi
  brew install gh
fi

GH_VERSION=$(gh --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
if version_gte "$GH_VERSION" "$REQUIRED_GH_VERSION"; then
  ok "gh $GH_VERSION installed"
else
  warn "gh $GH_VERSION found — $REQUIRED_GH_VERSION+ recommended. Run: brew upgrade gh"
fi

# ── 2. SSH for GitHub ────────────────────────────────────────────────────────

info "Configuring SSH for $GHE_HOST..."
bash "$SCRIPT_DIR/setup-ssh.sh"

# ── 3. GitHub authentication ───────────────────────────────────────────────

info "Checking authentication for $GHE_HOST..."

if gh auth status --hostname "$GHE_HOST" &>/dev/null; then
  ok "Already authenticated to $GHE_HOST"
else
  info "Not authenticated — starting login for $GHE_HOST (git protocol: $GIT_PROTOCOL)..."
  gh auth login --hostname "$GHE_HOST" --web --git-protocol "$GIT_PROTOCOL"
  if gh auth status --hostname "$GHE_HOST" &>/dev/null; then
    ok "Authenticated to $GHE_HOST"
  else
    fail "Authentication to $GHE_HOST failed"
  fi
fi

# ── 4. GITHUB_TOKEN environment variable ─────────────────────────────────────

info "Checking GITHUB_TOKEN..."

if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  ok "GITHUB_TOKEN is set"
else
  warn "GITHUB_TOKEN is not set in your environment"
  echo ""
  echo "  The GitHub MCP server requires GITHUB_TOKEN to be exported."
  echo "  Generate a Personal Access Token on https://$GHE_HOST/settings/tokens"
  echo "  with 'repo' and 'read:org' scopes, then add to your shell profile:"
  echo ""
  echo "    export GITHUB_TOKEN=\"ghp_...\""
  echo ""
fi

# ── 5. APM ───────────────────────────────────────────────────────────────────

info "Checking APM..."

if command -v apm &>/dev/null; then
  APM_VERSION=$(apm --version 2>&1 | head -1)
  ok "APM installed ($APM_VERSION)"
else
  warn "APM not found — install with: brew tap microsoft/apm && brew install apm"
fi

# ── 6. Global DevCrew install ───────────────────────────────────────────────

info "Checking global DevCrew install..."

GLOBAL_MODULES="$HOME/.apm/apm_modules/praveenkumarsaravanan/devcrew"
if [[ -d "$GLOBAL_MODULES" ]] && grep -q "praveenkumarsaravanan/devcrew" "$HOME/.apm/apm.yml" 2>/dev/null; then
  ok "DevCrew installed globally (~/.apm/apm_modules/)"
else
  warn "DevCrew not installed globally yet"
  echo ""
  echo "  Run from this repo:"
  echo "    apm run install-global"
  echo ""
fi

# ── Summary ──────────────────────────────────────────────────────────────────

echo ""
info "Setup complete."
echo "  Project install:  apm install && apm run postinstall"
echo "  Global install:   apm run install-global"
echo "  Release:          apm run release -- --dry-run --ticket ISSUE-XXX"

# ── 7. Bootstrap project-level files ─────────────────────────────────────────

info "Bootstrapping project context and memory files..."

if [[ -t 0 ]]; then
  bash "$SCRIPT_DIR/init-context.sh"
else
  info "Non-interactive mode — skipping .project-context.md setup (run 'bash scripts/init-context.sh' manually or let the AI agent create it)"
fi

bash "$SCRIPT_DIR/init-memory.sh"

echo ""
ok "All done. Your project is ready for AI-native development with DevCrew."
