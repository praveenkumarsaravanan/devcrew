#!/usr/bin/env bash
set -euo pipefail

# Validates .agent.md and SKILL.md files for correct frontmatter format,
# required fields, naming conventions, and structural rules.
#
# Usage:
#   bash validate.sh                    # Validate all agents and skills
#   bash validate.sh --agents           # Validate agents only
#   bash validate.sh --skills           # Validate skills only
#   bash validate.sh --file PATH        # Validate a single file
#   bash validate.sh --json             # Output results as JSON
#   bash validate.sh --help             # Show usage
#
# Exit codes:
#   0 - All validations passed
#   1 - One or more validations failed
#   2 - Invalid arguments

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
AGENTS_DIR="$REPO_ROOT/.apm/agents"
SKILLS_DIR="$REPO_ROOT/.apm/skills"

ERRORS=()
WARNINGS=()
PASSED=0
FAILED=0
MODE="all"
JSON_OUTPUT=false
SINGLE_FILE=""

print_help() {
    sed -n '3,13p' "${BASH_SOURCE[0]}" | sed 's/^# \?//'
}

log_error() {
    local file="$1" msg="$2"
    ERRORS+=("$file: $msg")
    ((FAILED++)) || true
}

log_warning() {
    local file="$1" msg="$2"
    WARNINGS+=("$file: $msg")
}

log_pass() {
    ((PASSED++)) || true
}

validate_frontmatter_delimiters() {
    local file="$1"
    local first_line
    first_line=$(head -1 "$file")

    if [[ "$first_line" != "---" ]]; then
        log_error "$file" "Missing opening frontmatter delimiter (---) on line 1"
        return 1
    fi

    local closing_line=0
    local line_num=0
    while IFS= read -r line; do
        ((line_num++)) || true
        if [[ $line_num -gt 1 && "$line" == "---" ]]; then
            closing_line=$line_num
            break
        fi
    done < "$file"

    if [[ $closing_line -eq 0 ]]; then
        log_error "$file" "Missing closing frontmatter delimiter (---). Found opening --- but no closing ---"
        return 1
    fi

    return 0
}

extract_frontmatter_field() {
    local file="$1" field="$2"
    local in_frontmatter=false
    local line_num=0

    while IFS= read -r line; do
        ((line_num++)) || true
        if [[ $line_num -eq 1 && "$line" == "---" ]]; then
            in_frontmatter=true
            continue
        fi
        if [[ "$in_frontmatter" == true && "$line" == "---" ]]; then
            break
        fi
        if [[ "$in_frontmatter" == true ]]; then
            if [[ "$line" =~ ^${field}:\ *(.*) ]]; then
                local value="${BASH_REMATCH[1]}"
                value="${value#\"}"
                value="${value%\"}"
                value="${value#\'}"
                value="${value%\'}"
                echo "$value"
                return 0
            fi
        fi
    done < "$file"

    return 1
}

validate_agent() {
    local file="$1"
    local basename
    basename=$(basename "$file")
    local agent_name="${basename%.agent.md}"
    local checks_passed=true

    if ! validate_frontmatter_delimiters "$file"; then
        checks_passed=false
    fi

    local fm_name
    if fm_name=$(extract_frontmatter_field "$file" "name"); then
        if [[ "$fm_name" =~ ^##\  ]]; then
            log_error "$file" "name field has markdown heading prefix (## ). Remove '## ' prefix"
            checks_passed=false
        elif [[ "$fm_name" != "$agent_name" ]]; then
            log_error "$file" "name '$fm_name' does not match filename '$agent_name' (expected from $basename)"
            checks_passed=false
        fi

        if [[ "$fm_name" =~ [A-Z] ]]; then
            log_error "$file" "name '$fm_name' contains uppercase characters. Must be lowercase"
            checks_passed=false
        fi

        if [[ "$fm_name" =~ ^- || "$fm_name" =~ -$ ]]; then
            log_error "$file" "name '$fm_name' starts or ends with a hyphen"
            checks_passed=false
        fi

        if [[ "$fm_name" =~ -- ]]; then
            log_error "$file" "name '$fm_name' contains consecutive hyphens"
            checks_passed=false
        fi
    else
        log_error "$file" "Missing required field: name"
        checks_passed=false
    fi

    if ! extract_frontmatter_field "$file" "description" > /dev/null 2>&1; then
        local has_multiline_desc=false
        local in_frontmatter=false
        local line_num=0
        while IFS= read -r line; do
            ((line_num++)) || true
            if [[ $line_num -eq 1 && "$line" == "---" ]]; then
                in_frontmatter=true
                continue
            fi
            if [[ "$in_frontmatter" == true && "$line" == "---" ]]; then
                break
            fi
            if [[ "$in_frontmatter" == true && "$line" =~ ^description:$ ]]; then
                has_multiline_desc=true
                break
            fi
            if [[ "$in_frontmatter" == true && "$line" =~ ^description:\ *\> ]]; then
                has_multiline_desc=true
                break
            fi
            if [[ "$in_frontmatter" == true && "$line" =~ ^description:\ *\| ]]; then
                has_multiline_desc=true
                break
            fi
        done < "$file"

        if [[ "$has_multiline_desc" == false ]]; then
            log_error "$file" "Missing required field: description"
            checks_passed=false
        fi
    fi

    local line_count
    line_count=$(wc -l < "$file" | tr -d ' ')
    if [[ $line_count -gt 300 ]]; then
        log_warning "$file" "Agent definition is $line_count lines. Consider keeping under 300 for token efficiency"
    fi

    if [[ "$checks_passed" == true ]]; then
        log_pass
    fi
}

validate_skill() {
    local dir="$1"
    local skill_file="$dir/SKILL.md"
    local dir_name
    dir_name=$(basename "$dir")
    local checks_passed=true

    if [[ ! -f "$skill_file" ]]; then
        log_error "$dir" "Missing SKILL.md file"
        return
    fi

    if ! validate_frontmatter_delimiters "$skill_file"; then
        checks_passed=false
    fi

    local fm_name
    if fm_name=$(extract_frontmatter_field "$skill_file" "name"); then
        if [[ "$fm_name" != "$dir_name" ]]; then
            log_error "$skill_file" "name '$fm_name' does not match directory name '$dir_name'"
            checks_passed=false
        fi

        if [[ "$fm_name" =~ [A-Z] ]]; then
            log_error "$skill_file" "name '$fm_name' contains uppercase characters. Must be lowercase"
            checks_passed=false
        fi

        if [[ "$fm_name" =~ ^- || "$fm_name" =~ -$ ]]; then
            log_error "$skill_file" "name '$fm_name' starts or ends with a hyphen"
            checks_passed=false
        fi

        if [[ "$fm_name" =~ -- ]]; then
            log_error "$skill_file" "name '$fm_name' contains consecutive hyphens"
            checks_passed=false
        fi

        if [[ ${#fm_name} -gt 64 ]]; then
            log_error "$skill_file" "name '$fm_name' exceeds 64 characters (${#fm_name} chars)"
            checks_passed=false
        fi
    else
        log_error "$skill_file" "Missing required field: name"
        checks_passed=false
    fi

    if ! extract_frontmatter_field "$skill_file" "description" > /dev/null 2>&1; then
        local has_multiline_desc=false
        local in_frontmatter=false
        local line_num=0
        while IFS= read -r line; do
            ((line_num++)) || true
            if [[ $line_num -eq 1 && "$line" == "---" ]]; then
                in_frontmatter=true
                continue
            fi
            if [[ "$in_frontmatter" == true && "$line" == "---" ]]; then
                break
            fi
            if [[ "$in_frontmatter" == true && "$line" =~ ^description: ]]; then
                has_multiline_desc=true
                break
            fi
        done < "$skill_file"

        if [[ "$has_multiline_desc" == false ]]; then
            log_error "$skill_file" "Missing required field: description"
            checks_passed=false
        fi
    fi

    local line_count
    line_count=$(wc -l < "$skill_file" | tr -d ' ')
    if [[ $line_count -gt 500 ]]; then
        log_error "$skill_file" "SKILL.md is $line_count lines. Must be under 500 lines per agentskills.io spec"
        checks_passed=false
    elif [[ $line_count -gt 400 ]]; then
        log_warning "$skill_file" "SKILL.md is $line_count lines. Approaching the 500-line limit"
    fi

    for script in "$dir"/scripts/*.sh; do
        [[ -f "$script" ]] || continue
        if ! grep -q '\-\-help' "$script"; then
            log_warning "$script" "Script does not implement --help flag"
        fi
    done

    if [[ "$checks_passed" == true ]]; then
        log_pass
    fi
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help) print_help; exit 0 ;;
        --agents) MODE="agents"; shift ;;
        --skills) MODE="skills"; shift ;;
        --json) JSON_OUTPUT=true; shift ;;
        --file) SINGLE_FILE="$2"; shift 2 ;;
        *) echo "Unknown option: $1" >&2; print_help; exit 2 ;;
    esac
done

if [[ -n "$SINGLE_FILE" ]]; then
    if [[ "$SINGLE_FILE" == *.agent.md ]]; then
        validate_agent "$SINGLE_FILE"
    elif [[ "$(basename "$SINGLE_FILE")" == "SKILL.md" ]]; then
        validate_skill "$(dirname "$SINGLE_FILE")"
    else
        echo "Unknown file type: $SINGLE_FILE (expected *.agent.md or SKILL.md)" >&2
        exit 2
    fi
else
    if [[ "$MODE" == "all" || "$MODE" == "agents" ]]; then
        if [[ -d "$AGENTS_DIR" ]]; then
            for agent_file in "$AGENTS_DIR"/*.agent.md; do
                [[ -f "$agent_file" ]] || continue
                validate_agent "$agent_file"
            done
        fi
    fi

    if [[ "$MODE" == "all" || "$MODE" == "skills" ]]; then
        if [[ -d "$SKILLS_DIR" ]]; then
            for skill_dir in "$SKILLS_DIR"/*/; do
                [[ -d "$skill_dir" ]] || continue
                validate_skill "$skill_dir"
            done
        fi
    fi
fi

TOTAL=$((PASSED + FAILED))

if [[ "$JSON_OUTPUT" == true ]]; then
    echo "{"
    echo "  \"total\": $TOTAL,"
    echo "  \"passed\": $PASSED,"
    echo "  \"failed\": $FAILED,"
    echo "  \"warnings\": ${#WARNINGS[@]},"
    echo "  \"errors\": ["
    for i in "${!ERRORS[@]}"; do
        printf '    "%s"' "${ERRORS[$i]//\"/\\\"}"
        [[ $i -lt $((${#ERRORS[@]} - 1)) ]] && echo "," || echo ""
    done
    echo "  ]"
    echo "}"
else
    echo ""
    echo "=== APM Validation Report ==="
    echo ""

    if [[ ${#ERRORS[@]} -gt 0 ]]; then
        echo "ERRORS:"
        for err in "${ERRORS[@]}"; do
            echo "  ✗ $err"
        done
        echo ""
    fi

    if [[ ${#WARNINGS[@]} -gt 0 ]]; then
        echo "WARNINGS:"
        for warn in "${WARNINGS[@]}"; do
            echo "  ! $warn"
        done
        echo ""
    fi

    echo "Results: $PASSED passed, $FAILED failed, ${#WARNINGS[@]} warnings (out of $TOTAL checked)"

    if [[ $FAILED -gt 0 ]]; then
        echo ""
        echo "Fix the errors above, then re-run: bash $(basename "${BASH_SOURCE[0]}")"
    else
        echo ""
        echo "All validations passed. Run 'apm compile' to generate output files."
    fi
fi

if [[ $FAILED -gt 0 ]]; then
    exit 1
fi
exit 0
