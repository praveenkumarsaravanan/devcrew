# IaC Review

Review an infrastructure-as-code or image-build change from the Infrastructure Reviewer perspective.

## Inputs

- IaC/image diff or changed files.
- Target environment: dev, staging, production, or shared platform.
- Tooling involved: Terraform/OpenTofu, CDK, CloudFormation, Pulumi, SAM, Helm, Kubernetes, Dockerfile, Packer, or image pipeline.

## Review Steps

1. Activate `infrastructure-as-code`; also activate `image-build` for Dockerfile, container, AMI, or Packer changes.
2. Activate cloud-specific guidance such as `aws-application-development` when AWS resources are involved.
3. Review remote state, locking, plan/diff/change-set evidence, provider/module pinning, and drift detection.
4. Review secrets safety across vars, state, outputs, templates, tags, image layers, build args, examples, and logs.
5. Review IAM/resource policies, public exposure, network ingress, encryption, and destructive actions.
6. Review image scanning, base image pinning, SBOM/provenance, non-root runtime, and immutable artifact promotion.
7. Review rollback or forward-fix strategy and environment parity.

## Output

Return findings first, ordered by severity, with file/line references when available.

End with:

- Infrastructure summary.
- Plan/state verdict.
- Secrets/scanning verdict.
- Rollback/parity verdict.
- Overall recommendation: Approve or Request Changes.
