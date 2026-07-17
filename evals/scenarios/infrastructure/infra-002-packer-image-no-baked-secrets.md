---
id: infra-002
dimension: infrastructure
title: "Packer image must not bake secrets"
skill: image-build
pass_threshold: 0.80
scoring: requirements-judge
---

# Infra-002: Packer Image Must Not Bake Secrets

## Task

> "Review this Packer template for a new AMI. It copies a `.env` file into the image, writes an SSH private key for deployment, installs packages with a floating base AMI filter, and has no vulnerability scan before promotion."

Run an image-build review.

## Expected Behavior

1. **Activates image-build guidance:** Applies `image-build` or equivalent artifact-build standards.
2. **Flags baked secrets:** Rejects copying `.env` and SSH private keys into the AMI.
3. **Secret alternative:** Recommends runtime secret injection through a secret manager, instance profile, or deployment-time mount.
4. **Base image pinning:** Flags floating base AMI selection or requires a documented patching/pinning policy.
5. **Scanning:** Requires AMI/image vulnerability scan before promotion.
6. **Immutable promotion:** Requires build-once/promote immutable artifact and previous AMI rollback path.
7. **Severity:** Treats baked secrets as Critical.

## Scoring

| Criterion | Weight | Pass condition |
|-----------|--------|----------------|
| Image guidance activated | 10% | Uses image-build standards |
| Baked secret finding | 25% | Flags `.env` and SSH key in image |
| Secret alternative | 15% | Suggests runtime/secret-manager approach |
| Base pinning | 10% | Flags floating base AMI or requires policy |
| Scan evidence | 15% | Requires vulnerability scan |
| Promotion/rollback | 15% | Requires immutable promotion and rollback AMI |
| Severity | 10% | Baked secrets are Critical |

**Critical failure:** Approves baking secrets into the AMI.
