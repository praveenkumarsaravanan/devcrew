# New Team Package — Scaffold a Tier 2 Standards Package

Create a team-specific APM package that sits between root DevCrew (Tier 1) and individual projects (Tier 3). Team packages contain coding standard overrides, domain-specific skills, and team workflows.

## Hosting Options

| Option | Location | Pros | Cons |
|--------|----------|------|------|
| **Monorepo** (recommended) | `teams/<team-name>/` inside DevCrew repo | Single repo, unified versioning, simpler CI | Shared tag namespace |
| **Separate repo** | Standalone git repository | Independent versioning, access control | More repos to manage |

## Steps

1. **Activate the `team-package-management` skill** — it orchestrates the scaffolding.

2. **Provide team details:**
   - Team or org name (e.g., "payments-team", "platform-team", "mobile-team")
   - Primary domain (what kind of software does this team build?)
   - Hosting strategy: **Monorepo** (folder in DevCrew) or **Separate repo**

3. **Select DevCrew version to pin** as the base dependency.

4. **Review the scaffolded structure:**

   **Monorepo layout (at `devcrew/teams/<team-name>/`):**
   ```
   teams/<team-name>/
   ├── .apm/
   │   ├── instructions/     # Team coding standards overrides
   │   ├── skills/           # Team-specific skills
   │   ├── prompts/          # Team-specific workflows
   │   └── agents/           # Team-specific agent overrides
   ├── apm.yml               # Package manifest
   ├── apm-policy.yml        # Team governance policy
   └── README.md
   ```

   **Separate repo layout:**
   ```
   <team-name>-standards/
   ├── .apm/
   │   ├── instructions/
   │   ├── skills/
   │   ├── prompts/
   │   └── agents/
   ├── apm.yml               # Depends on DevCrew
   ├── apm-policy.yml
   └── README.md
   ```

5. **Add team standards.** The scaffold includes example overrides to get started. Add your team's specific:
   - Coding standard overrides (e.g., stricter auth rules for payments team)
   - Domain-specific spec templates (e.g., `payment-endpoint.spec.md`)
   - Team-specific workflows (e.g., PCI compliance check)

6. **Publish and consume:**
   - **Monorepo:** Projects consume via `directory: teams/<team-name>` in their `apm.yml`
   - **Separate repo:** Tag and push (`git tag v1.0.0 && git push --tags`), projects consume via git URL

## When to Use This

| Situation | Use |
|-----------|-----|
| Your team needs shared standards beyond DevCrew defaults | **`/new-team-package`** (this prompt) |
| You're starting a new project | `/new-project` (optionally references a team package) |
| You want to override a specific DevCrew primitive | Create the override directly in your team package's `.apm/` directory |
