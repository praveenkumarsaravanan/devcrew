#!/usr/bin/env bash
set -euo pipefail

MIGRATION_FILE="${1:-}"
EXIT_CODE=0
WARNINGS=0
ERRORS=0

RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

usage() {
    echo "Usage: $(basename "$0") <migration.sql>"
    echo ""
    echo "Validates a SQL migration file for common dangerous patterns."
    echo "Exits with non-zero code if critical issues are found."
    exit 1
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    WARNINGS=$((WARNINGS + 1))
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    ERRORS=$((ERRORS + 1))
    EXIT_CODE=1
}

info() {
    echo -e "${GREEN}[OK]${NC} $1"
}

if [ -z "$MIGRATION_FILE" ]; then
    usage
fi

if [ ! -f "$MIGRATION_FILE" ]; then
    echo "File not found: $MIGRATION_FILE"
    exit 1
fi

echo "============================================"
echo " Migration Validator"
echo " File: $MIGRATION_FILE"
echo "============================================"
echo ""

CONTENT=$(cat "$MIGRATION_FILE")
UPPER_CONTENT=$(echo "$CONTENT" | tr '[:lower:]' '[:upper:]')

# --- Check: DROP TABLE without IF EXISTS ---
if echo "$UPPER_CONTENT" | grep -qE 'DROP\s+TABLE' ; then
    if echo "$UPPER_CONTENT" | grep -qE 'DROP\s+TABLE\s+IF\s+EXISTS'; then
        info "DROP TABLE uses IF EXISTS"
    else
        error "DROP TABLE without IF EXISTS — risk of failure if table does not exist"
    fi
fi

# --- Check: DROP COLUMN without IF EXISTS ---
if echo "$UPPER_CONTENT" | grep -qE 'DROP\s+COLUMN' ; then
    if echo "$UPPER_CONTENT" | grep -qE 'DROP\s+COLUMN\s+IF\s+EXISTS'; then
        info "DROP COLUMN uses IF EXISTS"
    else
        warn "DROP COLUMN without IF EXISTS — consider adding for idempotency"
    fi
fi

# --- Check: ADD COLUMN NOT NULL without DEFAULT ---
if echo "$UPPER_CONTENT" | grep -qE 'ADD\s+COLUMN.*NOT\s+NULL'; then
    if echo "$UPPER_CONTENT" | grep -qE 'ADD\s+COLUMN.*NOT\s+NULL.*DEFAULT'; then
        info "ADD COLUMN NOT NULL has a DEFAULT value"
    elif echo "$UPPER_CONTENT" | grep -qE 'ADD\s+COLUMN.*DEFAULT.*NOT\s+NULL'; then
        info "ADD COLUMN NOT NULL has a DEFAULT value"
    else
        error "ADD COLUMN with NOT NULL but no DEFAULT — will fail on tables with existing rows (or rewrite the table)"
    fi
fi

# --- Check: LOCK TABLE ---
if echo "$UPPER_CONTENT" | grep -qE 'LOCK\s+TABLE'; then
    error "Explicit LOCK TABLE detected — this will block concurrent access"
fi

# --- Check: Non-concurrent index creation ---
if echo "$UPPER_CONTENT" | grep -qE 'CREATE\s+INDEX'; then
    if echo "$UPPER_CONTENT" | grep -qE 'CREATE\s+INDEX\s+CONCURRENTLY'; then
        info "CREATE INDEX uses CONCURRENTLY"
    else
        warn "CREATE INDEX without CONCURRENTLY — will lock the table during index creation (PostgreSQL)"
    fi
fi

if echo "$UPPER_CONTENT" | grep -qE 'CREATE\s+UNIQUE\s+INDEX'; then
    if echo "$UPPER_CONTENT" | grep -qE 'CREATE\s+UNIQUE\s+INDEX\s+CONCURRENTLY'; then
        info "CREATE UNIQUE INDEX uses CONCURRENTLY"
    else
        warn "CREATE UNIQUE INDEX without CONCURRENTLY — will lock the table during index creation (PostgreSQL)"
    fi
fi

# --- Check: TRUNCATE TABLE ---
if echo "$UPPER_CONTENT" | grep -qE 'TRUNCATE\s+TABLE'; then
    error "TRUNCATE TABLE detected — this deletes all data and is not easily reversible"
fi

# --- Check: ALTER COLUMN TYPE (column type change) ---
if echo "$UPPER_CONTENT" | grep -qE 'ALTER\s+COLUMN.*TYPE'; then
    warn "ALTER COLUMN TYPE detected — this may rewrite the table and lock it for the duration"
fi

# --- Check: RENAME COLUMN ---
if echo "$UPPER_CONTENT" | grep -qE 'RENAME\s+COLUMN'; then
    warn "RENAME COLUMN detected — this is a breaking change if existing code references the old name"
fi

# --- Check: RENAME TABLE ---
if echo "$UPPER_CONTENT" | grep -qE 'RENAME\s+TABLE|RENAME\s+TO'; then
    warn "RENAME TABLE detected — this is a breaking change if existing code references the old name"
fi

# --- Check: Data manipulation in migration ---
if echo "$UPPER_CONTENT" | grep -qE '^\s*(UPDATE|DELETE\s+FROM|INSERT\s+INTO)'; then
    warn "Data manipulation (UPDATE/DELETE/INSERT) detected in migration — consider separating schema changes from data migrations"
fi

# --- Check: Missing rollback / down migration ---
MIGRATION_DIR=$(dirname "$MIGRATION_FILE")
MIGRATION_BASE=$(basename "$MIGRATION_FILE")

ROLLBACK_FOUND=false
for pattern in "down" "rollback" "revert"; do
    CANDIDATE="${MIGRATION_DIR}/${MIGRATION_BASE/.up./.down.}"
    CANDIDATE2="${MIGRATION_DIR}/${MIGRATION_BASE/.sql/_rollback.sql}"
    CANDIDATE3="${MIGRATION_DIR}/${MIGRATION_BASE/.sql/_down.sql}"

    if [ -f "$CANDIDATE" ] || [ -f "$CANDIDATE2" ] || [ -f "$CANDIDATE3" ]; then
        ROLLBACK_FOUND=true
        break
    fi
done

if echo "$MIGRATION_BASE" | grep -qiE '(down|rollback|revert)'; then
    ROLLBACK_FOUND=true
fi

if [ "$ROLLBACK_FOUND" = true ]; then
    info "Corresponding rollback migration found (or this is a rollback migration)"
else
    warn "No corresponding rollback/down migration found — ensure a rollback plan exists"
fi

# --- Summary ---
echo ""
echo "============================================"
echo " Summary"
echo "============================================"
echo -e " Errors:   ${RED}${ERRORS}${NC}"
echo -e " Warnings: ${YELLOW}${WARNINGS}${NC}"
echo ""

if [ "$EXIT_CODE" -ne 0 ]; then
    echo -e "${RED}FAILED${NC} — Critical issues must be resolved before merging."
else
    if [ "$WARNINGS" -gt 0 ]; then
        echo -e "${YELLOW}PASSED WITH WARNINGS${NC} — Review warnings before merging."
    else
        echo -e "${GREEN}PASSED${NC} — No issues detected."
    fi
fi

exit "$EXIT_CODE"
