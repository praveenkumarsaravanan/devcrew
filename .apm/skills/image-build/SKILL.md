---
name: image-build
description: >
  Container and AMI image build guidance for Dockerfiles, Packer templates,
  base images, SBOMs, vulnerability scanning, baked-secret prevention,
  provenance, and immutable artifact promotion.
---

# Image Build

## Trigger

Activate this skill when:

- The user asks to build, review, or update container images, AMIs, Packer templates, Dockerfiles, OCI images, or image pipelines.
- A change modifies image build scripts, base images, package installation, runtime users, SBOM/provenance, or image promotion.
- DevOps, release readiness, or infrastructure review needs artifact-build safety guidance.

## Workflow

### 1. Identify Artifact Type

| Artifact | Examples | Review focus |
|---|---|---|
| Container image | Dockerfile, Containerfile, BuildKit, ECR/GHCR | base image, layers, secrets, scan, runtime user |
| AMI | Packer templates, EC2 image pipeline | hardening, patching, baked secrets, ownership |
| Build artifact | zip/package for Lambda or service deploy | reproducibility, provenance, immutability |

### 2. Build Hygiene

- Use pinned base images or digests for production artifacts.
- Build once and promote the same immutable artifact across environments.
- Do not rebuild per environment with different dependencies.
- Keep build steps reproducible and deterministic where practical.
- Use multi-stage builds to keep runtime images minimal.
- Run as non-root unless the runtime has a documented reason.
- Remove package manager caches, temporary files, and build-only tools from runtime images.

### 3. Secret Safety

- Never bake secrets, tokens, SSH keys, certificates, cloud credentials, or private registry credentials into images.
- Do not pass secrets through build args that can end up in image history.
- Use BuildKit secrets, CI secret mounts, or runtime secret injection.
- Scan image layers and build logs for accidental secrets when the pipeline supports it.

### 4. Security Scanning And Provenance

- Scan images before promotion using Trivy, Grype, Docker Scout, ECR scanning, or the project's equivalent.
- Block critical/high vulnerabilities unless a documented exception exists.
- Generate SBOMs for production artifacts where supported.
- Sign images or capture provenance when the deployment platform supports it.
- Keep OS packages and language dependencies patched.

### 5. Runtime Readiness

- Define health checks for services.
- Expose only required ports.
- Set resource limits in the orchestrator.
- Ensure graceful shutdown is supported.
- Keep logs structured and avoid writing secrets to stdout/stderr.

## Output

For image-build work, produce:

1. **Artifact summary** - Image/AMI/package, base image, runtime, registry.
2. **Security review** - secrets, user, base image, dependencies, vulnerabilities.
3. **Promotion model** - build once, promote immutable artifact, rollback image.
4. **Scan evidence** - scanner used, severity summary, exceptions.
5. **Required fixes** - Critical/Warning/Suggestion findings.

## Guardrails

- **Never bake secrets or credentials into images or AMIs.**
- **Never promote an unscanned production image.**
- **Never rebuild production artifacts separately from staging artifacts.**
- **Never run containers as root without a documented reason.**
- **Never use floating base tags for production without a compensating digest/pinning policy.**

## See Also

- **`infrastructure-as-code`** - IaC review for the deployment environment that consumes images.
- **`devops-engineer`** - Pipeline and deployment strategy.
- **`release-readiness`** - Release gate that verifies image scan and promotion evidence.
