---
name: typescript-node-baseline
description: Server-side TypeScript/Node safety rules and routing to typescript-node-standards
applyTo: "**/*.{ts,tsx,js,jsx,mts,cts,mjs,cjs,json,yml,yaml}"
---

# TypeScript Node Baseline

Apply these rules when the file is server-side TypeScript/Node code, an API route, a worker, a scheduled job, queue consumer, server config, or backend test. For browser-only UI code, use `react-standards` instead.

## Route To Standards

When working on server-side Node.js, activate `typescript-node-standards` for the full checklist.

## Required Checks

- Validate untrusted inputs at runtime: HTTP body, params, query, headers, env vars, queue payloads, webhooks, and external API responses.
- Use strict TypeScript. Avoid `any`; use `unknown` and narrow it.
- Keep `process.env` reads inside one typed config module.
- Handle async failures at every API, worker, job, and CLI boundary.
- Set explicit timeouts for outbound HTTP, SDK, database, cache, and queue operations.
- Redact secrets, tokens, cookies, authorization headers, and PII from logs.
- Make workers and event handlers idempotent before adding retries.
- Add tests for validation, error paths, timeout/retry behavior, and idempotency when those paths are touched.

## Do Not Allow

- Raw request payloads flowing into services without validation.
- Queue consumers that can process the same event twice and create duplicate side effects.
- `console.log` or logger calls that include full headers, cookies, tokens, secrets, raw request bodies, or sensitive records.
- Floating promises unless they are intentionally detached through a named helper that logs and tracks failures.
- User-controlled strings interpolated into SQL, shell commands, filesystem paths, or outbound URLs.
