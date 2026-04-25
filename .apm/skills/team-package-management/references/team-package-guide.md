# Team Package Guide

## What Belongs at Each Tier

| Primitive | Tier 1 — Root DevCrew | Tier 2 — Team Package | Tier 3 — Project |
|-----------|----------------------|----------------------|------------------|
| **Agents** | Universal roles (senior-dev, qa-lead) | Domain-tuned overrides (e.g., fintech-senior-dev) | Project-specific agent tweaks |
| **Skills** | Cross-cutting skills (apm-authoring, testing) | Team domain skills (e.g., payment-gateway-integration) | One-off project skills |
| **Instructions** | Org-wide standards (coding-standards, security-baseline) | Team conventions (e.g., stricter linting, domain naming rules) | Project-local overrides |
| **Prompts** | General workflows (/new-project, /review) | Team workflows (/deploy-payments, /rotate-keys) | Project shortcuts |
| **Spec templates** | Universal spec format | Domain-specific sections (compliance, SLA) | Project-specific fields |
| **Memory** | Org-wide decisions and ADRs | Team-scoped decisions and context | Project history |
| **Hooks** | Standard lifecycle hooks | Team CI/CD hooks, domain validations | Project-specific automations |

**Rule of thumb:** If more than one team would benefit, it belongs in Tier 1. If only your team uses it, Tier 2. If only one repo uses it, Tier 3.

## Override Mechanics

APM resolves primitives bottom-up: Tier 3 > Tier 2 > Tier 1. A file at the same relative path in a higher-priority tier replaces the lower-tier version entirely.

### Example 1: Override a DevCrew instruction

DevCrew defines `.apm/instructions/coding-standards.instructions.md`. To override it for your team, create the same path in your team package:

```
teams/payments-team/.apm/instructions/coding-standards.instructions.md
```

The team version completely replaces the DevCrew version for any project that depends on this team package.

### Example 2: Add a new team skill

New primitives don't override anything — they extend the available set:

```
teams/payments-team/.apm/skills/pci-compliance/SKILL.md
```

Projects inheriting from this team package gain the `pci-compliance` skill without affecting DevCrew.

### Example 3: Override an agent definition

DevCrew defines `.apm/agents/senior-developer.agent.md`. The team can specialize it:

```
teams/payments-team/.apm/agents/senior-developer.agent.md
```

Projects depending on `payments-team` get the team's version of the senior-developer agent.

## Consumption Patterns

### Monorepo (team folder lives inside DevCrew)

In the consuming project's `apm.yml`:

```yaml
name: my-payments-service
version: "1.0.0"
dependencies:
  apm:
    - git: "https://github.com/praveenkumarsaravanan/devcrew.git"
      ref: "v1.2.0"
      directory: teams/payments-team
```

The `directory` field tells APM to resolve the team package from a subdirectory of the DevCrew repo. The project inherits both DevCrew (Tier 1) and the team package (Tier 2) from a single dependency.

### Separate repo

```yaml
name: my-payments-service
version: "1.0.0"
dependencies:
  apm:
    - git: "https://github.com/praveenkumarsaravanan/devcrew.git"
      ref: "v1.2.0"
    - git: "https://github.com/my-org/payments-team-standards.git"
      ref: "v2.0.0"
```

APM layers the two dependencies in order: DevCrew first, then the team package on top.

## Extracting from Monorepo to Separate Repo

When a team outgrows the monorepo approach (needs independent versioning, access control, or CI):

1. **Create a new repo** — e.g., `payments-team-standards`.
2. **Move contents** — Copy `teams/payments-team/` from DevCrew to the new repo root. The `.apm/`, `apm.yml`, `apm-policy.yml`, and `README.md` should sit at the repo root.
3. **Add DevCrew dependency** — Update the new repo's `apm.yml`:
   ```yaml
   dependencies:
     apm:
       - git: "https://github.com/praveenkumarsaravanan/devcrew.git"
         ref: "v1.2.0"
   ```
4. **Update consuming projects** — Replace the `directory`-based dependency with the new repo URL.
5. **Remove from DevCrew** — Delete `teams/payments-team/` from the monorepo and commit.
6. **Tag initial release** — Tag the new repo as `v1.0.0` so consumers can pin to it.

## Governance Policy

The `apm-policy.yml` file declares the team package's governance boundaries:

```yaml
override_scope:
  # Primitives this team package is allowed to override from Tier 1
  allow:
    - instructions/coding-standards.instructions.md
    - agents/senior-developer.agent.md
  # Primitives that must never be overridden
  deny:
    - instructions/security-baseline.instructions.md

required_instructions:
  # Instructions that projects consuming this package must not remove
  - instructions/coding-standards.instructions.md

contact:
  team: payments-team
  slack: "#payments-eng"
  owner: payments-tech-lead
```

- **`override_scope`** — Declares which Tier 1 primitives the team may override. Helps catch accidental overrides during review.
- **`required_instructions`** — Instructions that consuming projects must keep active. Prevents teams from silently dropping standards.
- **`contact`** — Team ownership info for governance and escalation.
