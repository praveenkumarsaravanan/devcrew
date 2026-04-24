---
name: security-baseline
description: Universal security rules and discipline routing to java-standards or react-standards
applyTo: "**/*.{ts,tsx,js,jsx,java,sql,yml,yaml,json,html}"
---

# Security Baseline

These universal security rules apply to all code. For discipline-specific
security standards, activate the appropriate skill below.

## Discipline Routing

| Project type   | Activate skill     |
|----------------|--------------------|
| Java backend   | `java-standards`   |
| React frontend | `react-standards`  |
| Fullstack      | Both skills        |
| Other (Go, Python, Node.js, Angular, Vue, etc.) | No discipline-specific skill yet — apply the universal rules below |

Use `project-detection` when the discipline is unclear.

## Secrets Management

- Never commit secrets, API keys, tokens, or credentials to source control. Use pre-commit hooks (`detect-secrets`, `gitleaks`) to prevent accidental commits.
- Store secrets in environment variables or a dedicated secret manager (AWS Secrets Manager, HashiCorp Vault, GCP Secret Manager).
- Rotate credentials on a quarterly cadence at minimum. Automate rotation where possible.
- Use distinct credentials per environment (dev, staging, production). Never share secrets across environments.
- Revoke credentials immediately when team members leave or roles change.

## Authentication

- Use short-lived access tokens. JWT expiry should be under 1 hour.
- Implement refresh token rotation — each refresh token is single-use and issues a new refresh token alongside the access token.
- Enforce multi-factor authentication (MFA) for all admin and privileged operations.
- Hash passwords with bcrypt, scrypt, or Argon2. Never use MD5 or SHA-256 alone for password hashing.
- Implement account lockout or exponential backoff after repeated failed login attempts.
- Invalidate all sessions on password change.

## Authorization

- Check permissions at every endpoint (backend). Never rely on client-side route guards as the sole authorization mechanism.
- Use RBAC or ABAC depending on complexity requirements.
- Default to deny. Explicitly grant access rather than explicitly restricting it.
- Validate resource ownership — users can only access their own resources unless explicitly authorized.
- Log all authorization failures for security monitoring.

## API Security

- Rate limit all endpoints. Stricter limits for authentication endpoints.
- Implement CORS properly: restrict allowed origins to known domains, no wildcard (`*`) in production.
- Return minimal error information to clients. No stack traces, SQL errors, or internal IPs in responses.
- Use security headers on all responses:
  - `Strict-Transport-Security: max-age=31536000; includeSubDomains`
  - `X-Content-Type-Options: nosniff`
  - `X-Frame-Options: DENY`
  - `Content-Security-Policy: default-src 'self'`
  - `Referrer-Policy: strict-origin-when-cross-origin`
  - `Permissions-Policy: camera=(), microphone=(), geolocation=()`
- Implement request size limits to prevent DoS via oversized payloads.
- Log API requests with enough detail for audit trails without logging sensitive bodies.
