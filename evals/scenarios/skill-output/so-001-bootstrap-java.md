---
id: SO-001
dimension: skill-output
skill: project-bootstrap
name: Scaffold a Java Spring Boot API
pass_threshold: 0.70
scoring: skill-output-judge
---

# SO-001: Scaffold a Java Spring Boot API

## Task

> Scaffold a new backend project: Java 21, Spring Boot 3.3, PostgreSQL, REST API.
> The project is called "order-service" and uses Jira with project key ORD.

Give this task to the `project-bootstrap` skill.

## Expected Behavior

1. Creates a valid `apm.yml` with DevCrew as a dependency.
2. Creates `.project-context.md` with correct values:
   - discipline: backend
   - stack: Java 21, Spring Boot 3.3, PostgreSQL
   - tracker: jira
   - tracker-project-key: ORD
3. Creates `.memory.md` with empty domain sections.
4. Generates stack-specific starter files (e.g., `pom.xml` or `build.gradle`, `application.yml`, main class).
5. Initializes git repository.
6. Runs (or instructs to run) `apm install`.

## Scoring

| Criterion | Weight | Pass |
|-----------|--------|------|
| `apm.yml` created with correct name and DevCrew dependency | 20% | File exists, name = order-service, dependencies include devcrew |
| `.project-context.md` populated with correct field values | 25% | All 4 fields above are correct |
| `.memory.md` created with domain section headers | 10% | File exists with ≥3 domain headings |
| Stack-specific files generated | 25% | At least `pom.xml`/`build.gradle` + main class + config file |
| Git initialized | 10% | `.git/` directory created |
| APM install triggered or instructed | 10% | Either ran `apm install` or told the user to |

**Critical failure:** Generates files for the wrong stack (e.g., React files for a Java project).
