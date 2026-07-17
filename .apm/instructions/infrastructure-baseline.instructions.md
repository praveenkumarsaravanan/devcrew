---
name: infrastructure-baseline
description: Always-on infrastructure safety checks for IaC, deployment manifests, Dockerfiles, Packer, and image build configuration
applyTo: "**/*.{tf,tfvars,hcl,json,yml,yaml,template,cfn,ts,tsx,js,jsx,py,go,java,Dockerfile,Containerfile}"
---

# Infrastructure Baseline

Apply these checks when a file defines infrastructure, deployment configuration, image builds, AMI builds, Terraform/OpenTofu, CDK, CloudFormation, Pulumi, SAM, Helm, Kubernetes, Dockerfiles, or Packer templates.

## Required Checks

- Shared or production Terraform/OpenTofu uses remote state and locking.
- Plans, diffs, previews, or change sets are reviewed before apply/deploy.
- Secrets do not appear in variables, tfvars, state, outputs, templates, tags, images, AMIs, build args, examples, or logs.
- IaC changes are scanned with an appropriate tool when available.
- IAM, resource policies, public exposure, and network ingress are least privilege.
- Destructive or replacement actions have explicit approval and rollback or forward-fix strategy.
- Environments use the same modules/templates with parameterized inputs.
- Production drift detection exists or is listed as a gap.
- Container and AMI images are scanned before promotion.
- Production artifacts are immutable and promoted across environments instead of rebuilt per environment.

## Do Not Allow

- Local state for shared or production infrastructure.
- Unreviewed `apply`, deploy, or destructive changes.
- Hardcoded cloud credentials, private keys, certificates, tokens, or passwords.
- Secrets passed through image build args or baked into image layers.
- Floating base image tags without digest pinning or a documented policy.
- Production IaC/image changes with no rollback, forward-fix, or mitigation path.
