---
description: Security baseline requirements for all backend services
applyTo: "**/*.{ts,js,py,go,java,rs,sql,yml,yaml,json}"
---

# Security Baseline

## Secrets Management

- Never commit secrets, API keys, tokens, or credentials to source control. Use pre-commit hooks (e.g., `detect-secrets`, `gitleaks`) to prevent accidental commits.
- Store secrets in environment variables or a dedicated secret manager (AWS Secrets Manager, HashiCorp Vault, GCP Secret Manager).
- Rotate credentials on a quarterly cadence at minimum. Automate rotation where possible.
- Use distinct credentials per environment (dev, staging, production). Never share secrets across environments.
- Revoke credentials immediately when team members leave or roles change.

## Input Validation

- Validate all user input at API boundaries before any processing occurs.
- Use allowlists over denylists. Define what is permitted rather than trying to enumerate what is forbidden.
- Sanitize input before database queries, template rendering, and shell execution.
- Enforce type, length, format, and range constraints on all inputs. Reject early with clear error messages.
- Never trust client-side validation alone. Always re-validate on the server.

## Authentication

- Use short-lived access tokens. JWT expiry should be under 1 hour.
- Implement refresh token rotation — each refresh token is single-use and issues a new refresh token alongside the access token.
- Enforce multi-factor authentication (MFA) for all admin and privileged operations.
- Hash passwords with a modern algorithm (bcrypt, scrypt, or Argon2) with appropriate work factors.
- Implement account lockout or exponential backoff after repeated failed login attempts.
- Invalidate all sessions on password change.

## Authorization

- Check permissions at every endpoint. Never rely on client-side route guards alone.
- Use Role-Based Access Control (RBAC) or Attribute-Based Access Control (ABAC) depending on complexity requirements.
- Default to deny. Explicitly grant access rather than explicitly restricting it.
- Validate resource ownership — ensure users can only access their own resources unless explicitly authorized otherwise.
- Log all authorization failures for security monitoring.

## Data Protection

- Encrypt data at rest using AES-256 or equivalent.
- Encrypt data in transit using TLS 1.2+ for all connections, including internal service-to-service communication.
- Use parameterized queries for all database operations. Never construct queries via string concatenation.
- Mask PII (personally identifiable information) in logs, error messages, and monitoring dashboards.
- Implement data retention policies. Do not store data longer than necessary.
- Classify data by sensitivity level and apply controls proportional to the classification.

## Dependency Security

- Pin dependency versions in lock files. Use exact versions, not ranges.
- Run vulnerability scans (e.g., `npm audit`, `safety`, `govulncheck`, Snyk, Dependabot) in CI on every build.
- Do not merge code that introduces dependencies with known critical CVEs.
- Review new dependencies before adoption: check maintenance status, known vulnerabilities, license, and transitive dependencies.
- Subscribe to security advisories for critical dependencies.

## API Security

- Rate limit all endpoints. Use tiered limits: stricter for authentication endpoints, more generous for read-only endpoints.
- Validate `Content-Type` headers on all requests that accept a body. Reject unexpected content types.
- Implement CORS properly: restrict allowed origins to known domains, do not use wildcard (`*`) in production.
- Return minimal error information to clients. Internal details (stack traces, SQL errors, internal IPs) must never leak in API responses.
- Use security headers: `Strict-Transport-Security`, `X-Content-Type-Options`, `X-Frame-Options`, `Content-Security-Policy`.
- Implement request size limits to prevent denial-of-service via oversized payloads.
- Log all API requests with enough detail for audit trails (who, what, when, from where) without logging sensitive request/response bodies.
