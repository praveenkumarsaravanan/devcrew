#!/usr/bin/env bash
set -euo pipefail

# Bootstraps a minimal .project-context.md in the consumer project.
# Runs during `apm install` (via scripts.setup) or manually.
# The AI agent enriches this file later with conversational detail.

CONTEXT_FILE=".project-context.md"

info()  { printf "\033[1;34m▸ %s\033[0m\n" "$1"; }
ok()    { printf "\033[1;32m✓ %s\033[0m\n" "$1"; }
warn()  { printf "\033[1;33m⚠ %s\033[0m\n" "$1"; }

# ── Skip if already exists ───────────────────────────────────────────────────

if [[ -f "$CONTEXT_FILE" ]]; then
  ok "$CONTEXT_FILE already exists — skipping (agent will enrich on next run)"
  exit 0
fi

# ── Detect defaults ──────────────────────────────────────────────────────────

DEFAULT_NAME=$(basename "$(pwd)")
DEFAULT_DATE=$(date +%Y-%m-%d)

detect_git_platform() {
  local url
  url=$(git remote get-url origin 2>/dev/null || echo "")
  case "$url" in
    *github.com*)       echo "github" ;;
    *gitlab.com*)       echo "gitlab" ;;
    *bitbucket.org*)    echo "bitbucket" ;;
    *dev.azure.com*|*visualstudio.com*) echo "azure-repos" ;;
    *github.*)          echo "ghe" ;;
    *)                  echo "" ;;
  esac
}

detect_discipline() {
  if [[ -f "pom.xml" || -f "build.gradle" || -f "go.mod" || -f "Cargo.toml" ]]; then
    echo "backend"
  elif [[ -f "angular.json" || -f "vite.config.ts" || -f "vite.config.js" ]]; then
    echo "frontend"
  elif [[ -f "next.config.js" || -f "next.config.mjs" || -f "next.config.ts" || -f "nuxt.config.ts" ]]; then
    echo "fullstack"
  elif [[ -f "package.json" ]]; then
    if grep -q '"react"' package.json 2>/dev/null; then
      echo "frontend"
    elif grep -q '"express"\|"fastify"\|"@nestjs"' package.json 2>/dev/null; then
      echo "backend"
    else
      echo ""
    fi
  elif [[ -f "requirements.txt" || -f "pyproject.toml" ]]; then
    echo "backend"
  else
    echo ""
  fi
}

GIT_PLATFORM=$(detect_git_platform)
DISCIPLINE=$(detect_discipline)

# ── Interactive prompts ──────────────────────────────────────────────────────

info "Setting up project context (.project-context.md)"
echo ""

read -rp "  Project name [$DEFAULT_NAME]: " PROJECT_NAME
PROJECT_NAME="${PROJECT_NAME:-$DEFAULT_NAME}"

if [[ -n "$DISCIPLINE" ]]; then
  read -rp "  Discipline — detected: $DISCIPLINE [backend/frontend/fullstack/infrastructure]: " DISC_INPUT
  DISCIPLINE="${DISC_INPUT:-$DISCIPLINE}"
else
  read -rp "  Discipline [backend/frontend/fullstack/infrastructure]: " DISCIPLINE
  DISCIPLINE="${DISCIPLINE:-backend}"
fi

read -rp "  Stack (e.g., 'Java 21, Spring Boot 3.3, PostgreSQL 16'): " STACK
STACK="${STACK:-}"

echo ""
echo "  Task tracker:"
echo "    1) github-issues"
echo "    2) jira"
echo "    3) linear"
echo "    4) azure-devops"
echo "    5) none"
read -rp "  Choose [1-5, default=5]: " TRACKER_CHOICE
case "${TRACKER_CHOICE:-5}" in
  1) TRACKER="github-issues" ;;
  2) TRACKER="jira" ;;
  3) TRACKER="linear" ;;
  4) TRACKER="azure-devops" ;;
  *) TRACKER="none" ;;
esac

TRACKER_KEY=""
TRACKER_REPO=""
if [[ "$TRACKER" == "jira" ]]; then
  read -rp "  Jira project key (e.g., PROJ): " TRACKER_KEY
elif [[ "$TRACKER" == "github-issues" ]]; then
  DEFAULT_REPO=$(git remote get-url origin 2>/dev/null | sed 's/.*github\.com[:/]\(.*\)\.git/\1/' || echo "")
  read -rp "  GitHub repo for issues [$DEFAULT_REPO]: " TRACKER_REPO
  TRACKER_REPO="${TRACKER_REPO:-$DEFAULT_REPO}"
fi

echo ""
echo "  Execution mode:"
echo "    1) local      — subagents in current IDE"
echo "    2) background — Cursor Background Agents / Claude Code --background"
echo "    3) async      — decompose into tracker tasks"
echo "    4) manual     — produce plan only"
read -rp "  Choose [1-4, default=1]: " EXEC_CHOICE
case "${EXEC_CHOICE:-1}" in
  2) EXECUTION="background" ;;
  3) EXECUTION="async" ;;
  4) EXECUTION="manual" ;;
  *) EXECUTION="local" ;;
esac

if [[ -n "$GIT_PLATFORM" ]]; then
  read -rp "  Git platform — detected: $GIT_PLATFORM [github/ghe/gitlab/bitbucket/azure-repos]: " GP_INPUT
  GIT_PLATFORM="${GP_INPUT:-$GIT_PLATFORM}"
else
  read -rp "  Git platform [github/ghe/gitlab/bitbucket/azure-repos]: " GIT_PLATFORM
  GIT_PLATFORM="${GIT_PLATFORM:-github}"
fi

# ── Write file ───────────────────────────────────────────────────────────────

cat > "$CONTEXT_FILE" <<EOF
---
project-name: $PROJECT_NAME
discipline: $DISCIPLINE
stack: "$STACK"
tracker: $TRACKER
tracker-project-key: "$TRACKER_KEY"
tracker-repo: "$TRACKER_REPO"
execution: $EXECUTION
git-platform: $GIT_PLATFORM
migration-mode: false
created: $DEFAULT_DATE
last-updated: $DEFAULT_DATE
---

## Architecture Overview

<!-- High-level system description — the AI agent will enrich this section -->

## Technology Decisions

<!-- Key tech choices with rationale — the AI agent will enrich this section -->

## Team Conventions

<!-- Branching strategy, PR policy, naming conventions -->

## Notes

<!-- Anything else the team wants to persist across sessions -->
EOF

echo ""
ok "Created $CONTEXT_FILE"
info "The AI agent will enrich this file with additional detail on the next Engineering Flow run."
