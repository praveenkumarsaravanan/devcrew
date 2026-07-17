# Release Evidence

Build or review an evidence bundle for a medium or high-risk release.

## Steps

1. Activate `release-evidence`.
2. Capture release name/version, branch, commit SHA, PR, tickets, owner, changed components, environments, and risk classification.
3. Build an evidence matrix for scope/tickets, tests, security, IaC/image, data impact, contract compatibility, rollback, monitoring/runbooks, and approvals.
4. For each evidence item, mark Pass, Fail, Not Applicable, or Waived. Include links, command names, report IDs, owner, timestamp, or concise evidence notes.
5. For high-risk changes, require rollback and monitoring evidence before any Ready recommendation.
6. If infrastructure, images, data feeds, regulated data, or contracts are involved, activate the matching specialist skill and include its evidence requirements.
7. Identify Critical, Warning, and Suggestion gaps.
8. Return Ready, Ready with waivers, or Not ready.

## Output

Return release summary, evidence matrix, findings by severity, rollback and monitoring verdict, approvals needed, and final readiness recommendation.
