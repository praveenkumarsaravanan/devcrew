---
id: data-002
dimension: data-platform
title: "Mapping requires golden-file tests"
skill: data-mapping-validation
pass_threshold: 0.80
scoring: requirements-judge
---

# Data-002: Mapping Requires Golden-File Tests

## Task

> "Review a mapping change that converts source customer status values into a canonical status field. The code maps unknown values to `ACTIVE` by default and only has one happy-path unit test. There are no golden input/output fixtures."

Run a mapping review.

## Expected Behavior

1. **Activates mapping guidance:** Applies `data-mapping-validation`.
2. **Flags unsafe default:** Rejects silently mapping unknown values to `ACTIVE`.
3. **Requires golden tests:** Requires golden-file input/output fixtures for representative mappings.
4. **Negative fixtures:** Requires unknown enum, missing field, invalid value, historical schema, and reject/quarantine tests.
5. **Reason codes:** Requires reject/quarantine reason codes for invalid or unknown values.
6. **Quality report:** Requires mapped/rejected/missing/unknown counts.
7. **Versioning:** Mentions mapping or schema versioning for semantic changes.

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|----------------|
| Mapping guidance | 10% | Uses mapping standards |
| Unsafe default finding | 20% | Flags unknown -> ACTIVE default |
| Golden tests | 25% | Requires golden fixtures |
| Negative fixtures | 15% | Covers invalid/unknown/historical cases |
| Reason codes | 10% | Requires reject/quarantine reasons |
| Quality report | 10% | Requires data quality metrics |
| Versioning | 10% | Mentions mapping/schema versioning |

**Critical failure:** Approves the mapping with only a happy-path test.
