# [FEATURE NAME] - AWS Infrastructure Specification

## Problem Statement

[PLACEHOLDER: Describe the infrastructure capability being added or changed, who needs it, and why now.]

## Scope

| In scope | Out of scope |
|----------|--------------|
| [PLACEHOLDER] | [PLACEHOLDER] |

## Infrastructure Summary

| Field | Value |
|-------|-------|
| Environment | [dev / staging / prod / shared] |
| IaC tool | [Terraform / OpenTofu / CDK / CloudFormation / Pulumi / SAM] |
| AWS services | [PLACEHOLDER] |
| Data sensitivity | [none / internal / sensitive / regulated] |
| Blast radius | [PLACEHOLDER] |

## Resources

| Resource | Purpose | Environment | Owner | Tags |
|----------|---------|-------------|-------|------|
| [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] | `service`, `environment`, `owner`, `cost-center` |

## State And Deployment

| Concern | Requirement |
|---------|-------------|
| Remote state | [PLACEHOLDER] |
| Locking | [PLACEHOLDER] |
| Plan/diff evidence | [PLACEHOLDER] |
| Drift detection | [PLACEHOLDER] |
| Approval gate | [PLACEHOLDER] |

## Security

| Area | Requirement |
|------|-------------|
| IAM/resource policies | Least privilege; no broad wildcard without approval |
| Secrets | Referenced from secret manager; never in vars/state/outputs/templates |
| Encryption | KMS/service encryption for sensitive resources |
| Network exposure | [PLACEHOLDER] |
| Public access | [PLACEHOLDER: blocked unless explicitly approved] |

## Image And Artifact Requirements

| Artifact | Build source | Scan requirement | Promotion model |
|----------|--------------|------------------|-----------------|
| [PLACEHOLDER] | [Dockerfile/Packer/build pipeline] | [PLACEHOLDER] | Build once, promote immutable artifact |

## Rollback Or Forward-Fix

| Scenario | Action | Owner | Estimated recovery time |
|----------|--------|-------|-------------------------|
| [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] | [PLACEHOLDER] |

## Validation Plan

| Check | Evidence |
|-------|----------|
| IaC fmt/validate | [PLACEHOLDER] |
| IaC security scan | [PLACEHOLDER] |
| Plan/diff reviewed | [PLACEHOLDER] |
| Image/AMI scan | [PLACEHOLDER] |
| Smoke test | [PLACEHOLDER] |

## Handoff Checklist

- [ ] Remote state and locking confirmed
- [ ] Plan/diff reviewed
- [ ] Secrets absent from vars, state, outputs, templates, tags, image layers, and examples
- [ ] IaC scan complete or gap documented
- [ ] Image scan complete when images/AMIs are involved
- [ ] Rollback or forward-fix documented
- [ ] Drift detection requirement defined
- [ ] Human approval captured for high-risk or destructive changes
