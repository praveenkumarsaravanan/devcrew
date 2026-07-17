# [FEATURE NAME] - Data Mapping Specification

## Problem Statement

[PLACEHOLDER: Describe the mapping or transformation need, affected consumers, and why it is changing.]

## Scope

| In scope | Out of scope |
|----------|--------------|
| [PLACEHOLDER] | [PLACEHOLDER] |

## Mapping Summary

| Field | Value |
|-------|-------|
| Source schema/version | [PLACEHOLDER] |
| Target schema/version | [PLACEHOLDER] |
| Mapping version | [PLACEHOLDER] |
| Record identity | [PLACEHOLDER] |
| Data sensitivity | [PLACEHOLDER] |

## Mapping Rules

| Source field | Target field | Transform | Validation | Default / Reject behavior |
|--------------|--------------|-----------|------------|---------------------------|
| [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] |

## Error Handling

| Error type | Behavior | Reason code |
|------------|----------|-------------|
| Parser error | [PLACEHOLDER] | [PLACEHOLDER] |
| Validation error | [PLACEHOLDER] | [PLACEHOLDER] |
| Mapping error | [PLACEHOLDER] | [PLACEHOLDER] |
| Downstream write error | [PLACEHOLDER] | [PLACEHOLDER] |

## Golden-File Tests

| Fixture | Scenario | Expected output |
|---------|----------|-----------------|
| [PLACEHOLDER] | Happy path | [PLACEHOLDER] |
| [PLACEHOLDER] | Missing required field | Reject/quarantine |
| [PLACEHOLDER] | Unknown enum | Reject/quarantine or explicit mapping |
| [PLACEHOLDER] | Historical schema | [PLACEHOLDER] |

## Data Quality Report

| Metric | Threshold | Owner |
|--------|-----------|-------|
| mapped count | [PLACEHOLDER] | [PLACEHOLDER] |
| reject count / rate | [PLACEHOLDER] | [PLACEHOLDER] |
| missing key count | [PLACEHOLDER] | [PLACEHOLDER] |
| duplicate count | [PLACEHOLDER] | [PLACEHOLDER] |

## Handoff Checklist

- [ ] Mapping table reviewed
- [ ] Source/target schema versions identified
- [ ] Golden-file fixtures defined
- [ ] Reject/quarantine reason codes defined
- [ ] Data quality report defined
- [ ] Sensitive logging/reporting controls confirmed
