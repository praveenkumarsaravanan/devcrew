# Legacy Migrate — Onboard a Legacy Codebase to AI-Native Development

Assess an existing codebase and create a phased plan to adopt DevCrew's AI-native development workflow.

## What This Does

1. Classifies the codebase (discipline, stack, platform)
2. Assesses current state across 6 dimensions (tests, linting, security, CI/CD, docs, standards)
3. Produces a gap analysis comparing current state to DevCrew's target
4. Generates a phased migration plan (M0–M3) with concrete actions
5. Optionally creates tracker tickets for the migration work

## Steps

1. **Activate the `legacy-assessment` skill** — it orchestrates the entire assessment.

2. **Review the gap analysis.** The assessment scans your codebase and reports maturity across:
   - Test coverage
   - Linting and formatting
   - Security posture
   - CI/CD pipeline
   - Documentation
   - Standards compliance

3. **Review the phased migration plan.** Four phases:
   - **M0 — Wire In (Day 1):** Install DevCrew, run `/constitution`, enable `migration-standards`
   - **M1 — Safety Net (Week 1-2):** Linting, secret scanning, basic CI, critical path tests
   - **M2 — Standards Adoption (Week 3-6):** Enforce standards on new code, increase coverage, document architecture
   - **M3 — Steady State (Ongoing):** Full `coding-standards` enforcement, all work through `team-workflow`

4. **Wire in DevCrew:**
   - Generate `apm.yml` with DevCrew as a dependency
   - Run `apm install && apm compile`
   - The `migration-standards` instruction activates automatically (softer enforcement during migration)

5. **Create tracker tickets** (optional):
   - If a task tracker is configured, create an Epic/Milestone with child tickets for each migration phase
   - If no tracker, receive a Markdown task list

6. **Start building.** Once M0 is complete, begin using `team-workflow` for all new work. The migration-standards instruction ensures existing code isn't held to full standards until it's touched.

## When to Use This vs Other Options

| Situation | Use |
|-----------|-----|
| Existing codebase, no DevCrew yet | **`/legacy-migrate`** (this prompt) |
| Starting a brand new project | `/new-project` |
| Project already has DevCrew installed | Just use `team-workflow` directly |

## Important

- The assessment is **read-only** — no code changes are made during analysis.
- Security gaps are always prioritized over style gaps.
- Existing code is grandfathered — only new or touched code must meet standards.
