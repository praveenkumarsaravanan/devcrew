---
name: triage
description: First-pass production-issue triage — evidence-backed hypothesis for human review
---

# Triage

Run first-pass triage on a production issue. Activate the `triage` skill and follow its hard rules.

Arguments: `<incident_no> <service-repo> [release-tag]` (service/tag optional — resolve the repo if not given).

1. **Ingest the failure artifact first** (exception report / error log / failure notice) if one exists — match the exact error string to its source before any code hypothesis.
2. **Resolve the owning repo** by enumerating candidates, not anchoring on the first match.
3. **Get a pinned, isolated checkout** (git mirror + worktree at the deployed ref) — never the working copy. Record the ref.
4. **Read whole functions top-to-bottom; trace every input variable to its source** before naming a cause.
5. **Write a hypothesis card** (status: hypothesis): summary, root cause + confidence, evidence (file:line), blast radius, what would confirm/kill it, limits, next steps. State the ref triaged.

Diagnostic confidence must be earned by traced evidence, not asserted. If you haven't read the whole function and traced the inputs, say "insufficient evidence — here's what I'd check" rather than naming a cause. Do not write to confirmed incident memory — that happens via `/postmortem`.
