# Dependency Audit

Audit the project's dependencies for security vulnerabilities, license risks, and maintenance health.

1. **Detect the ecosystem** — Identify the package manager(s) in use:
   - npm/yarn/pnpm → `npm audit` / `yarn audit`
   - Python → `pip-audit` / `safety check`
   - Go → `govulncheck ./...`
   - Java (Gradle) → `./gradlew dependencyCheckAnalyze`
   - Java (Maven) → `mvn dependency-check:check`
   - Rust → `cargo audit`

2. **Run vulnerability scans** — Execute the appropriate audit command. Classify findings:
   - **Critical**: actively exploited or RCE. Must fix before merge.
   - **High**: network-exploitable or data exposure. Fix within the sprint.
   - **Medium**: requires local access or unusual conditions. Plan a fix.
   - **Low**: theoretical or informational. Track and batch.

3. **License review** — List dependencies with non-permissive licenses (GPL, AGPL, SSPL, EUPL). Flag any that conflict with the project's license or org policy.

4. **Maintenance health** — Flag dependencies that are:
   - Unmaintained (no release in 12+ months).
   - Deprecated (marked in the registry).
   - Heavily transitive (pulling in 50+ sub-dependencies).

5. **Recommendations** — For each finding, recommend: upgrade to patched version, replace with alternative, or accept with justification.

Provide a summary table with: dependency name, current version, finding, severity, and recommended action.
