#!/usr/bin/env bash
set -euo pipefail

# Validates all APM artifacts: agents, skills, instructions, prompts, and hooks.
#
# Usage:
#   bash validate.sh                    # Validate everything
#   bash validate.sh --agents           # Agents only
#   bash validate.sh --skills           # Skills only
#   bash validate.sh --instructions     # Instructions only
#   bash validate.sh --prompts          # Prompts only
#   bash validate.sh --hooks            # Hooks only
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
INSTRUCTIONS_DIR="$REPO_ROOT/.apm/instructions"
PROMPTS_DIR="$REPO_ROOT/.apm/prompts"
HOOKS_DIR="$REPO_ROOT/.apm/hooks"

ERRORS=()
WARNINGS=()
PASSED=0
FAILED=0
MODE="all"
JSON_OUTPUT=false
SINGLE_FILE=""

print_help() {
    sed -n '3,19p' "${BASH_SOURCE[0]}" | sed 's/^# \?//'
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

has_frontmatter_field() {
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
        if [[ "$in_frontmatter" == true && "$line" =~ ^${field}: ]]; then
            return 0
        fi
    done < "$file"

    return 1
}

validate_name_rules() {
    local file="$1" name="$2"

    if [[ "$name" =~ ^##\  ]]; then
        log_error "$file" "name field has markdown heading prefix (## ). Remove '## ' prefix"
        return 1
    fi

    local valid=true

    if [[ "$name" =~ [A-Z] ]]; then
        log_error "$file" "name '$name' contains uppercase characters. Must be lowercase"
        valid=false
    fi

    if [[ "$name" =~ ^- || "$name" =~ -$ ]]; then
        log_error "$file" "name '$name' starts or ends with a hyphen"
        valid=false
    fi

    if [[ "$name" =~ -- ]]; then
        log_error "$file" "name '$name' contains consecutive hyphens"
        valid=false
    fi

    if [[ ${#name} -gt 64 ]]; then
        log_error "$file" "name '$name' exceeds 64 characters (${#name} chars)"
        valid=false
    fi

    [[ "$valid" == true ]]
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
        if ! validate_name_rules "$file" "$fm_name"; then
            checks_passed=false
        elif [[ "$fm_name" != "$agent_name" ]]; then
            log_error "$file" "name '$fm_name' does not match filename '$agent_name' (expected from $basename)"
            checks_passed=false
        fi
    else
        log_error "$file" "Missing required field: name"
        checks_passed=false
    fi

    if ! has_frontmatter_field "$file" "description"; then
        log_error "$file" "Missing required field: description"
        checks_passed=false
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
        if ! validate_name_rules "$skill_file" "$fm_name"; then
            checks_passed=false
        elif [[ "$fm_name" != "$dir_name" ]]; then
            log_error "$skill_file" "name '$fm_name' does not match directory name '$dir_name'"
            checks_passed=false
        fi
    else
        log_error "$skill_file" "Missing required field: name"
        checks_passed=false
    fi

    if ! has_frontmatter_field "$skill_file" "description"; then
        log_error "$skill_file" "Missing required field: description"
        checks_passed=false
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

validate_instruction() {
    local file="$1"
    local basename
    basename=$(basename "$file")
    local checks_passed=true

    if ! validate_frontmatter_delimiters "$file"; then
        checks_passed=false
    fi

    if ! has_frontmatter_field "$file" "description"; then
        log_error "$file" "Missing required field: description"
        checks_passed=false
    fi

    if ! has_frontmatter_field "$file" "applyTo"; then
        log_error "$file" "Missing required field: applyTo (glob pattern for target files)"
        checks_passed=false
    fi

    if [[ ! "$basename" == *.instructions.md ]]; then
        log_error "$file" "Filename must end with .instructions.md (got: $basename)"
        checks_passed=false
    fi

    if [[ "$checks_passed" == true ]]; then
        log_pass
    fi
}

validate_prompt() {
    local file="$1"
    local basename
    basename=$(basename "$file")
    local checks_passed=true

    if [[ ! "$basename" == *.prompt.md ]]; then
        log_error "$file" "Filename must end with .prompt.md (got: $basename)"
        checks_passed=false
    fi

    local first_line
    first_line=$(head -1 "$file")
    if [[ "$first_line" != "#"* ]]; then
        log_warning "$file" "Prompt should start with a # heading on line 1"
    fi

    local line_count
    line_count=$(wc -l < "$file" | tr -d ' ')
    if [[ $line_count -gt 100 ]]; then
        log_warning "$file" "Prompt is $line_count lines. Consider keeping under 100 for token efficiency"
    fi

    if [[ $line_count -lt 3 ]]; then
        log_error "$file" "Prompt is only $line_count lines. Too short to be useful"
        checks_passed=false
    fi

    if [[ "$checks_passed" == true ]]; then
        log_pass
    fi
}

validate_hook() {
    local file="$1"
    local basename
    basename=$(basename "$file")
    local checks_passed=true

    if [[ ! "$basename" == *.json ]]; then
        log_error "$file" "Hook file must be JSON (got: $basename)"
        checks_passed=false
    fi

    if ! python3 -c "import json; json.load(open('$file'))" 2>/dev/null; then
        log_error "$file" "Invalid JSON syntax"
        checks_passed=false
    else
        if ! python3 -c "
import json, sys
data = json.load(open('$file'))
if 'version' not in data:
    print('missing_version')
    sys.exit(1)
if 'hooks' not in data:
    print('missing_hooks')
    sys.exit(1)
" 2>/dev/null; then
            local result
            result=$(python3 -c "
import json, sys
data = json.load(open('$file'))
if 'version' not in data:
    print('Missing required field: version')
if 'hooks' not in data:
    print('Missing required field: hooks')
" 2>/dev/null) || true
            if [[ -n "$result" ]]; then
                log_error "$file" "$result"
                checks_passed=false
            fi
        fi

        local hook_count
        hook_count=$(python3 -c "
import json
data = json.load(open('$file'))
count = 0
for event in data.get('hooks', {}).values():
    count += len(event)
print(count)
" 2>/dev/null) || hook_count=0
        if [[ "$hook_count" -eq 0 ]]; then
            log_warning "$file" "Hook file has no hook definitions"
        fi
    fi

    if [[ "$checks_passed" == true ]]; then
        log_pass
    fi
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help) print_help; exit 0 ;;
        --agents) MODE="agents"; shift ;;
        --skills) MODE="skills"; shift ;;
        --instructions) MODE="instructions"; shift ;;
        --prompts) MODE="prompts"; shift ;;
        --hooks) MODE="hooks"; shift ;;
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
    elif [[ "$SINGLE_FILE" == *.instructions.md ]]; then
        validate_instruction "$SINGLE_FILE"
    elif [[ "$SINGLE_FILE" == *.prompt.md ]]; then
        validate_prompt "$SINGLE_FILE"
    elif [[ "$SINGLE_FILE" == *.json ]]; then
        validate_hook "$SINGLE_FILE"
    else
        echo "Unknown file type: $SINGLE_FILE" >&2
        echo "Expected: *.agent.md, SKILL.md, *.instructions.md, *.prompt.md, or *.json" >&2
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

    if [[ "$MODE" == "all" || "$MODE" == "instructions" ]]; then
        if [[ -d "$INSTRUCTIONS_DIR" ]]; then
            for instr_file in "$INSTRUCTIONS_DIR"/*.instructions.md; do
                [[ -f "$instr_file" ]] || continue
                validate_instruction "$instr_file"
            done
        fi
    fi

    if [[ "$MODE" == "all" || "$MODE" == "prompts" ]]; then
        if [[ -d "$PROMPTS_DIR" ]]; then
            for prompt_file in "$PROMPTS_DIR"/*.prompt.md; do
                [[ -f "$prompt_file" ]] || continue
                validate_prompt "$prompt_file"
            done
        fi
    fi

    if [[ "$MODE" == "all" || "$MODE" == "hooks" ]]; then
        if [[ -d "$HOOKS_DIR" ]]; then
            for hook_file in "$HOOKS_DIR"/*.json; do
                [[ -f "$hook_file" ]] || continue
                validate_hook "$hook_file"
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
