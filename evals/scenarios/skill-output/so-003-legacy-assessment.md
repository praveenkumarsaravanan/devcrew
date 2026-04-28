---
id: SO-003
dimension: skill-output
skill: legacy-assessment
name: Assess a legacy Java codebase
pass_threshold: 0.70
scoring: skill-output-judge
---

# SO-003: Assess a Legacy Java Codebase

## Task

> Assess this existing Java project for AI-native migration readiness.
> The project has: Maven build, JUnit 4 tests (30% coverage), no CI pipeline,
> a README.md but no architecture docs, Spring Boot 2.7, Java 11.

Provide a mock project structure (or describe the above to the agent) and activate the `legacy-assessment` skill.

## Expected Behavior

1. Produces a structured gap analysis covering:
   - Build system status (Maven — present)
   - Test coverage assessment (JUnit 4, 30% — low)
   - CI/CD status (missing)
   - Documentation status (README only — partial)
   - Framework/language currency (Spring Boot 2.7 / Java 11 — outdated)
2. Generates a phased migration plan with M0 through M3 milestones.
3. Identifies specific upgrade recommendations (Java 11 → 17+, Spring Boot 2.7 → 3.x, JUnit 4 → 5).
4. Does NOT suggest rewriting the entire application.

## Scoring

| Criterion | Weight | Pass |
|-----------|--------|------|
| Gap analysis covers all 5 areas | 25% | All areas addressed with findings |
| Migration plan has phased milestones (M0–M3) | 25% | At least 3 phases with concrete actions |
| Identifies version upgrade needs | 20% | Mentions Java, Spring Boot, and JUnit upgrades |
| Recommends incremental approach (not full rewrite) | 15% | Explicitly preserves existing code |
| Produces structured output (not freeform paragraphs) | 15% | Uses headings, tables, or clear sections |

**Critical failure:** Recommends deleting and rewriting the codebase from scratch.
