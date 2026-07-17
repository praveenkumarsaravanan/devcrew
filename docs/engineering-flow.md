# DevCrew Engineering Flow

DevCrew Engineering Flow is the user-facing development lifecycle for build, fix, and change work.

Use:

```text
/engineering-flow Add validation to the booking form
```

The internal implementation skill remains `team-workflow` for compatibility, but the user-facing name and command are Engineering Flow.

## What It Does

Engineering Flow right-sizes each request before implementation:

| Task size | Default path |
|---|---|
| Quick fix | Detection -> Implementation -> Lightweight review |
| Standard change | Detection -> Light requirements -> Implementation -> Review -> Test verification |
| Full feature | Detection -> Requirements -> Architecture -> Implementation -> Review -> Test strategy -> Test implementation |

Phase 0 also assigns risk and council depth:

| Council depth | Used for | Output |
|---|---|---|
| Light | Quick fixes | One-line Chair note |
| Standard | Most standard/full work | Concise Council Brief |
| Deep | Explicit request, ambiguity, architecture/security/data/IaC trade-offs | Options, trade-off matrix, recommendation, checkpoint |

Deep mode:

```text
/engineering-flow --deep Design retry handling for this worker
```

Planning only:

```text
/convene-council Compare options for the webhook contract migration
```

## How Councils Fit

Councils do not replace the workflow. They make routing visible.

The Council Chair explains:

- Task size, risk, and council depth
- Active and skipped councils
- Which specialist skills or reviewers apply
- Trade-offs and checkpoints
- Which phase runs next

Specialist lanes activate only when signaled by the task or codebase:

| Signal | Added guidance |
|---|---|
| TypeScript/Node API, worker, job | `typescript-node-standards`, `typescript-node-reviewer` |
| AWS app or AWS IaC | `aws-application-development`, `aws-platform-reviewer` |
| Terraform/CDK/CloudFormation/Pulumi/Helm/Kubernetes | `infrastructure-as-code`, `infrastructure-reviewer` |
| Dockerfile, AMI, Packer, image pipeline | `image-build`, `infrastructure-reviewer` |
| Data feed, mapping, replay, reconciliation | `data-ingestion`, `data-mapping-validation`, `operational-feed-runbook`, `data-platform-reviewer` |
| OpenAPI, AsyncAPI, webhook, event, protobuf, file/feed contract | `interoperability-contracts`, `interoperability-reviewer` |
| Sensitive or regulated data | `regulated-data-handling`, `regulated-data-reviewer` |

## Handoffs

Each phase emits a compact handoff:

```text
### Phase [N] Handoff: [Phase Name]
Discipline:
Task size:
Risk:
Council depth:
Decision:
Artifacts:
Constraints for next phase:
Open questions:
```

The next phase receives the handoff, not the whole conversation. This keeps context focused and reduces self-agreement during architecture, review, and test phases.

## Post-Merge Prompts

Engineering Flow is pre-merge by default. Post-merge and release work is opt-in:

| Need | Prompt |
|---|---|
| Deployment plan | `/devops-plan` |
| Release evidence | `/release-evidence` |
| Go/no-go decision | `/release-readiness` |
| Monitoring and runbooks | `/monitoring-plan` |
| Incident response (severity/comms) | `/incident-response` |
| Production issue triage (hypothesis) | `/triage` |
| Post-incident close-out | `/postmortem` |

### Triage vs incident response vs debugging

See **[triage.md](triage.md)**. **Rule of thumb:** production hypothesis → `triage`; active incident ops → `/incident-response`; dev/staging → `debugging`.

### FHIR / HL7

See **[fhir-health-interop.md](fhir-health-interop.md)** for build vs review routing and IG bundle setup. **Rule of thumb:** build → `fhir-health-interop` skill; audit → `/fhir-review`.

## Useful References

- [Council Model](council-model.md)
- [Triage guide](triage.md)
- [FHIR / HL7 guide](fhir-health-interop.md)
- [Generic Platform Support](generic-platform-support.md)
- [Data Platform Workflow](data-platform-workflow.md)
- [TypeScript/Node And AWS Workflow](typescript-node-aws-workflow.md)
- [Documentation layering](documentation-layering.md) — where to add vs remove content
- [DevCrew Index](devcrew-index.md) — full primitive catalog including triage and FHIR
