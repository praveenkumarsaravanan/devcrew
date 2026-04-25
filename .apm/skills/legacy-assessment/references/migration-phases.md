# Migration Phases

Phased adoption roadmap for migrating an existing codebase to AI-native development with DevCrew.
Adjust timelines based on codebase size, team capacity, and gap analysis results.

---

## M0 — Wire In (Day 1)

**Objective:** Install DevCrew and establish the project context so all subsequent work uses the framework.

### Action Items

- [ ] Install DevCrew via APM (`apm install devcrew`)
- [ ] Run `/constitution` to generate the project constitution
- [ ] Enable the `migration-standards` instruction (grandfathers existing code)
- [ ] Create `.project-context.md` with project metadata, team, and stack info
- [ ] Verify `project-detection` correctly classifies the codebase discipline and stack
- [ ] Commit DevCrew configuration files to the repository

### Exit Criteria

- DevCrew is installed and configured
- `.project-context.md` exists and is accurate
- `migration-standards` instruction is active
- Team can invoke DevCrew skills from their IDE

**Estimated effort:** 1-2 hours

---

## M1 — Safety Net (Week 1-2)

**Objective:** Establish the minimum safety infrastructure so AI-assisted changes are guarded by automated checks.

### Action Items

- [ ] Add linting configuration for the project's language (ESLint, Checkstyle, Ruff, etc.)
- [ ] Add code formatter configuration (Prettier, google-java-format, Black, etc.)
- [ ] Set up pre-commit hooks for lint + format checks
- [ ] Configure secret scanning (`.gitleaks.toml` or equivalent)
- [ ] Run dependency audit and resolve critical/high vulnerabilities
- [ ] Create or update CI pipeline with: build, lint, and test stages
- [ ] Write tests for the 3-5 most critical code paths (happy path + key error cases)
- [ ] Enable test execution in CI with failure gates
- [ ] Document the local development setup in `README.md`

### Exit Criteria

- Linter and formatter run on every commit (pre-commit hooks)
- Secret scanning is active in CI
- Critical dependencies have no known high/critical vulnerabilities
- CI pipeline runs build + lint + test on every PR
- Critical paths have at least basic test coverage

**Estimated effort:** 3-5 days

---

## M2 — Standards Adoption (Week 3-6)

**Objective:** Gradually raise code quality so new code meets DevCrew standards while existing code is improved when touched.

### Action Items

- [ ] Enable `coding-standards` instruction for new/modified files
- [ ] Increase test coverage to 60%+ (focus on business logic and integrations)
- [ ] Add integration tests for key API endpoints or user flows
- [ ] Document top 3-5 architectural decisions as ADRs
- [ ] Generate or update API documentation (OpenAPI spec, JSDoc, Javadoc)
- [ ] Set up structured logging with correlation IDs
- [ ] Configure SAST tooling in CI (CodeQL, Semgrep, or equivalent)
- [ ] Run `code-review` skill on 2-3 recent PRs to calibrate quality bar
- [ ] Begin using `team-workflow` for new feature development

### Exit Criteria

- All new code passes `coding-standards` checks
- Test coverage is at or above 60%
- Key architectural decisions are documented
- SAST runs in CI on every PR
- Team has completed at least one feature using `team-workflow`

**Estimated effort:** 2-4 weeks

---

## M3 — Steady State (Ongoing)

**Objective:** The codebase operates fully under DevCrew governance. Migration scaffolding is removed.

### Action Items

- [ ] Disable `migration-standards` instruction
- [ ] Enable full `coding-standards` and `security-baseline` instructions
- [ ] Route all new work through `team-workflow` (requirements → architecture → implementation → review → QA)
- [ ] Target 80%+ test coverage across the codebase
- [ ] Set up monitoring and alerting (SLOs/SLIs) for production services
- [ ] Establish regular dependency update cadence (weekly or bi-weekly)
- [ ] Archive the migration Epic/tickets and close the migration project
- [ ] Update `.project-context.md` to reflect steady-state configuration

### Exit Criteria

- `migration-standards` is disabled; full standards are enforced
- All new features go through `team-workflow`
- Test coverage is at or above 80%
- No critical/high security vulnerabilities in dependencies
- Team operates autonomously with DevCrew without migration scaffolding

**Estimated effort:** Ongoing (transition completes in 1-2 sprints)

---

_Reference for the DevCrew `legacy-assessment` skill. See [assessment-template.md](assessment-template.md) for the report format._
