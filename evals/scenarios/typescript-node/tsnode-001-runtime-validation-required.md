---
id: tsnode-001
dimension: typescript-node
title: "Runtime validation required for Node API input"
skill: typescript-node-standards
pass_threshold: 0.80
scoring: requirements-judge
---

# TSNode-001: Runtime Validation Required For Node API Input

## Task

> "Review this Express route change. It accepts `req.body` as `CreateCustomerRequest` and passes it directly into `customerService.createCustomer(req.body)`. The handler relies on TypeScript types and does not use a runtime schema. It returns raw validation errors to the client."

Run a TypeScript/Node backend review.

## Expected Behavior

1. **Activates Node standards:** Applies `typescript-node-standards` or equivalent server-side TypeScript/Node guidance.
2. **Flags missing runtime validation:** Identifies that TypeScript types do not validate runtime request bodies.
3. **Boundary coverage:** Mentions body validation and may also check params, query, headers, env config, and external response validation.
4. **Safe error response:** Requires structured validation errors that do not expose raw parser internals, stack traces, or sensitive values.
5. **Concrete fix:** Recommends a runtime schema library or existing project validator and deriving static types from that schema when possible.
6. **Tests:** Requires tests for valid input, invalid input, and safe error output.
7. **Severity:** Marks the issue as Warning or Critical depending on the route sensitivity; it must not be treated as a mere style suggestion.

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|----------------|
| Node standards activated | 15% | Uses TypeScript/Node backend standards, not only generic TypeScript advice |
| Runtime validation finding | 25% | Clearly says compile-time types are insufficient for `req.body` |
| Safe errors | 15% | Requires safe structured validation response |
| Concrete remediation | 20% | Suggests schema validation and type derivation or local equivalent |
| Test coverage | 15% | Requires valid and invalid input tests |
| Severity | 10% | Treats the issue as merge-relevant |

**Critical failure:** Approves the route because the TypeScript type annotation is present.
