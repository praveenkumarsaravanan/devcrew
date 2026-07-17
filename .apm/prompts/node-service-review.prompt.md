# Node Service Review

Use this prompt to run a focused TypeScript/Node backend review outside the full Engineering Flow.

## Inputs

- Changed files or PR/diff to review.
- Project stack and framework, if known.
- Any known API, worker, scheduled job, queue, database, or external integration touched by the change.

## Review Steps

1. Detect whether the changed code is server-side TypeScript/Node, browser TypeScript, or mixed fullstack code.
2. Activate `typescript-node-standards` for server-side files. If the change includes React/browser code, also activate `react-standards`.
3. Review runtime validation at all untrusted boundaries.
4. Review async error handling, timeout behavior, retries, and structured error mapping.
5. Review logs for secret, token, cookie, authorization header, PII, or raw payload exposure.
6. For workers, queue consumers, and scheduled jobs, review idempotency, duplicate delivery, retry exhaustion, and dead-letter handling.
7. Review tests for validation, error paths, timeout/retry behavior, and idempotency.

## Output

Return findings first, ordered by severity, with file and line references.

End with:

- Runtime validation verdict.
- Sensitive logging verdict.
- Idempotency verdict when worker/job code is touched.
- Overall recommendation: Approve or Request Changes.
