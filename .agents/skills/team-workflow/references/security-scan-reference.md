# Security Scan Reference

Reference document for the Backend Reviewer during Phase 4 (Code Review). Use this checklist alongside the general code review process to ensure comprehensive security coverage.

## OWASP Top 10 Code Analysis Checklist

When reviewing changed files, actively look for these patterns:

| OWASP ID | Category | What to Look For |
|---|---|---|
| A01 | Broken Access Control | Missing auth/authz on endpoints, IDOR (direct object references without ownership checks), privilege escalation paths, CORS misconfiguration (`*` origins) |
| A02 | Cryptographic Failures | Weak algorithms (MD5, SHA1 for passwords), hardcoded keys/secrets, missing encryption for PII at rest or in transit, weak random number generation |
| A03 | Injection | SQL via string concatenation, command injection (`exec`, `spawn` with user input), template injection, LDAP injection, XSS in server-rendered output |
| A04 | Insecure Design | Missing rate limiting on sensitive endpoints, no account lockout, trust boundary violations (client input trusted without server validation), missing abuse-case handling |
| A05 | Security Misconfiguration | Verbose error messages exposing internals, debug mode enabled, default credentials, unnecessary HTTP methods enabled, missing security headers |
| A06 | Vulnerable Components | Outdated dependencies with known CVEs (run dependency audit — see below) |
| A07 | Auth Failures | Weak password policies, missing MFA for admin operations, session fixation, tokens that never expire, credentials in URLs |
| A08 | Data Integrity Failures | Insecure deserialization (untrusted data passed to `deserialize`, `pickle.loads`, `JSON.parse` without validation), missing integrity checks on critical updates |
| A09 | Logging Failures | PII in logs (emails, SSNs, tokens), missing audit trails for auth events, swallowed exceptions hiding security failures |
| A10 | SSRF | User-controlled URLs passed to HTTP clients (`fetch`, `axios`, `HttpClient`), unvalidated redirects, DNS rebinding risk |

## Dependency Audit Commands

Detect the project's build tool and run the appropriate audit. Report findings by severity.

| Build Tool | Detection | Command | Notes |
|---|---|---|---|
| npm | `package-lock.json` | `npm audit` | Use `--json` for parseable output |
| yarn | `yarn.lock` | `yarn audit` | Use `--json` for parseable output |
| Gradle | `build.gradle` or `build.gradle.kts` | `./gradlew dependencyCheckAnalyze` | Requires OWASP Dependency-Check plugin (`org.owasp.dependencycheck`). If not configured, flag the gap. |
| Maven | `pom.xml` | `mvn org.owasp:dependency-check-maven:check` | Runs without pom.xml changes. Report in `target/`. |
| Go | `go.mod` | `govulncheck ./...` | Shipped with Go toolchain. Install: `go install golang.org/x/vuln/cmd/govulncheck@latest` |
| Python | `requirements.txt` or `pyproject.toml` | `pip-audit` | Install: `pip install pip-audit`. If unavailable, flag the gap. |
| Rust | `Cargo.toml` | `cargo audit` | Install: `cargo install cargo-audit`. If unavailable, flag the gap. |

If the native audit tool is not available, fall back to CI posture check (see below) for dependency vulnerability data.

## CI Security Posture Check

Use `gh` CLI to verify the project's security tooling is enabled and check for open alerts:

```bash
# CodeQL / Code Scanning — open alerts
gh api /repos/{owner}/{repo}/code-scanning/alerts -q '[.[] | select(.state=="open")] | length'

# Dependabot — open dependency CVEs
gh api /repos/{owner}/{repo}/dependabot/alerts -q '[.[] | select(.state=="open")] | length'

# Secret Scanning — open leaked secrets
gh api /repos/{owner}/{repo}/secret-scanning/alerts -q '[.[] | select(.state=="open")] | length'
```

If any API returns a 404 or permission error, the feature is not enabled. Flag it as a posture gap.

Also verify that `.github/workflows/` contains a security scanning workflow (CodeQL, SonarQube, or equivalent). If missing, recommend adding one.

## Severity Mapping

When consolidating findings from different sources, normalize to the review's three severity levels:

| Review Severity | OWASP Code Analysis | npm audit / yarn audit | Dependabot | CodeQL | govulncheck |
|---|---|---|---|---|---|
| **Critical** | Injection, broken auth, SSRF, cryptographic failures with direct exposure | critical | critical | error | High-confidence matches |
| **Warning** | Misconfiguration, logging gaps, weak crypto without direct exposure, missing rate limits | high, moderate | high, medium | warning | Lower-confidence matches |
| **Suggestion** | Defense-in-depth improvements, best-practice deviations | low, info | low | note | N/A |

## Industry-Standard Tooling Reference

For teams configuring CI/CD security pipelines, these are the recommended tools by category:

| Category | Recommended Tools | Notes |
|---|---|---|
| **SAST** | CodeQL (GitHub native), SonarQube | CodeQL for security-focused dataflow analysis; SonarQube for broader quality + security |
| **SCA** | Dependabot (GitHub native), Trivy (`trivy fs .`) | Dependabot for auto-fix PRs; Trivy for CLI and multi-purpose scanning |
| **Secret Detection** | GitHub Secret Scanning, gitleaks | gitleaks for local/CI pre-commit scanning |
| **Container Scanning** | Trivy (`trivy image`), Grype | Run in CI after image build |
| **IaC Scanning** | Trivy (`trivy config`), Checkov | Run in CI for Terraform/Kubernetes/Helm |
| **DAST** | OWASP ZAP (`zap-api-scan.py`) | Industry-standard open-source DAST. Requires a running app. Use API scan mode with OpenAPI spec for backend services. |
