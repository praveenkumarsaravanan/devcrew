---
id: SO-004
dimension: skill-output
skill: team-package-management
name: Scaffold a Tier 2 team package
pass_threshold: 0.70
scoring: skill-output-judge
---

# SO-004: Scaffold a Tier 2 Team Package

## Task

> Create a new team package called "platform-team" for our backend Java team.
> It should be in the monorepo under teams/platform-team/.
> The team uses Java 21, Spring Boot 3.3, PostgreSQL, and Kafka.

Activate the `team-package-management` skill.

## Expected Behavior

1. Creates `teams/platform-team/apm.yml` with:
   - name: platform-team
   - DevCrew as a dependency
   - Correct target list
2. Creates `teams/platform-team/.apm/` directory structure with at least:
   - An instructions file for team-specific standards
   - A skill or agent placeholder
3. The package content is specific to the described stack (Java, Spring, Kafka).
4. Does NOT duplicate content that already exists in Tier 1 DevCrew.

## Scoring

| Criterion | Weight | Pass |
|-----------|--------|------|
| `apm.yml` created with correct structure | 25% | Valid YAML with name, dependency on devcrew |
| `.apm/` directory has at least instructions + one other primitive | 25% | ≥2 files in `.apm/` |
| Content is stack-specific (Java/Spring/Kafka) | 25% | References the team's stack, not generic |
| Does not duplicate Tier 1 content | 15% | No copy of team-workflow, code-review, etc. |
| Follows APM naming conventions | 10% | Correct file names and frontmatter |

**Critical failure:** Creates a package that conflicts with or overrides DevCrew's core workflow.
