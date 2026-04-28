---
id: SO-002
dimension: skill-output
skill: project-bootstrap
name: Scaffold a React TypeScript frontend
pass_threshold: 0.70
scoring: skill-output-judge
---

# SO-002: Scaffold a React TypeScript Frontend

## Task

> Scaffold a new frontend project: React 18, TypeScript, Tailwind CSS.
> The project is called "dashboard-ui" and uses GitHub Issues on org/dashboard-ui.

Give this task to the `project-bootstrap` skill.

## Expected Behavior

1. Creates a valid `apm.yml` with DevCrew as a dependency.
2. Creates `.project-context.md` with correct values:
   - discipline: frontend
   - stack: React 18, TypeScript, Tailwind CSS
   - tracker: github-issues
   - tracker-repo: org/dashboard-ui
3. Creates `.memory.md` with empty domain sections.
4. Generates stack-specific starter files (e.g., `package.json`, `tsconfig.json`, `tailwind.config.*`).
5. Initializes git repository.

## Scoring

| Criterion | Weight | Pass |
|-----------|--------|------|
| `apm.yml` created with correct name and DevCrew dependency | 20% | File exists, name = dashboard-ui |
| `.project-context.md` populated with correct field values | 25% | All 4 fields correct |
| `.memory.md` created with domain section headers | 10% | File exists with ≥3 domain headings |
| Stack-specific files generated | 25% | At least `package.json` + `tsconfig.json` + tailwind config |
| Git initialized | 10% | `.git/` directory created |
| APM install triggered or instructed | 10% | Either ran or instructed |

**Critical failure:** Generates Java/Spring files for a React project.
