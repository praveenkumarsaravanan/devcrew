#!/usr/bin/env bash
set -euo pipefail

REQUIRED_GH_VERSION="2.40.0"

info()  { printf "\033[1;34m▸ %s\033[0m\n" "$1"; }
ok()    { printf "\033[1;32m✓ %s\033[0m\n" "$1"; }
warn()  { printf "\033[1;33m⚠ %s\033[0m\n" "$1"; }
fail()  { printf "\033[1;31m✗ %s\033[0m\n" "$1"; exit 1; }

version_gte() {
  printf '%s\n%s' "$1" "$2" | sort -V | head -n1 | grep -qx "$2"
}

# ── 0. Load .env (if present) ────────────────────────────────────────────────

if [[ -f ".env" ]]; then
  info "Loading .env file..."
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
  ok "Loaded .env"
elif [[ -f ".env.example" && ! -f ".env" ]]; then
  info "No .env file found. Copy .env.example to .env and fill in your values:"
  echo "    cp .env.example .env"
  echo ""
fi

# ── 1. Required environment variables ────────────────────────────────────────

info "Checking required environment variables..."

if [[ -z "${GIT_HOST:-}" ]]; then
  fail "GIT_HOST is not set. Export it in your shell profile (e.g., export GIT_HOST=\"github.example.com\")"
fi
ok "GIT_HOST is set ($GIT_HOST)"

if [[ -z "${GIT_API_URL:-}" ]]; then
  warn "GIT_API_URL is not set — defaulting to https://$GIT_HOST/api/v3"
  echo "  To override, export GIT_API_URL in your shell profile."
  echo ""
fi

# ── 2. gh CLI ────────────────────────────────────────────────────────────────

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

# ── 3. GitHub authentication ─────────────────────────────────────────────────

info "Checking authentication for $GIT_HOST..."

if gh auth status --hostname "$GIT_HOST" &>/dev/null; then
  ok "Already authenticated to $GIT_HOST"
else
  info "Not authenticated — starting login for $GIT_HOST..."
  gh auth login --hostname "$GIT_HOST" --web --git-protocol https
  if gh auth status --hostname "$GIT_HOST" &>/dev/null; then
    ok "Authenticated to $GIT_HOST"
  else
    fail "Authentication to $GIT_HOST failed"
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
  echo "  Generate a Personal Access Token on https://$GIT_HOST/settings/tokens"
  echo "  with 'repo' and 'read:org' scopes, then add to your shell profile:"
  echo ""
  echo "    export GITHUB_TOKEN=\"<your-token>\""
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

# ── Summary ──────────────────────────────────────────────────────────────────

echo ""
info "Setup complete. Run 'apm install' to install package dependencies."
