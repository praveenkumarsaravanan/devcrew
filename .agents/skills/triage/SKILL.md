---
name: triage
description: >
  First-pass production-issue triage that produces an evidence-backed hypothesis
  for human review. Sets up an isolated, version-pinned checkout (git mirror +
  worktree), ingests the failure artifact first, reads whole functions and traces
  data lifecycle before naming a cause, and writes a triage card. Use when someone
  posts a production issue and you need a disciplined first pass — not a guess.
---

# Triage

First-pass triage for a production issue. Output is a **hypothesis for human review — never a verdict, never a confirmed root cause.** The discipline below exists to prevent confident-but-wrong directions; follow it in order.

## Trigger

Activate when:
- Someone posts a production issue / defect and wants a first-pass investigation.
- The user runs `/triage` (see the `triage` prompt) or asks "what's causing this issue."
- Use `/postmortem` (and the postmortem section below) once an incident is *fixed*.

For dev/staging debugging without a production incident, use the `debugging` skill instead. For severity/comms/escalation, use `/incident-response`.

## Hard rules (these prevent the most common failures)

1. **Ingest the failure artifact FIRST.** Exception report, error log, failure notice, output file — read it before forming any code hypothesis. One line of real data ("Duplicate entry. Member already exists") beats rounds of code reasoning. Match the exact message string to where it is produced in code.
2. **Read the WHOLE function, top to bottom — not a window around the matched line.** Start at the function signature. Root causes routinely sit a few lines above or below the symptom (e.g. a `DELETE` before a reuse).
3. **Trace EVERY input variable to its source before theorizing.** Confirm each input is still valid where it's used — was it mutated, deleted, or transformed earlier? Many bugs are data-lifecycle bugs (a variable reused after its backing data was destroyed), invisible unless you trace it.
4. **Investigate a fresh, version-pinned checkout — NEVER the developer's working copy.** Use a git mirror + worktree (below). The working copy is on the wrong branch with uncommitted changes; triaging it triages the wrong code.
5. **Diagnostic confidence must be EARNED, not asserted.** A confident wrong root cause is worse than an honest "not yet confirmed — here's what I'd check." State a confidence level; if you haven't done rules 1–3, say "insufficient evidence" rather than naming a cause. This overrides the usual bias toward decisiveness: be decisive about *recommendations*, calibrated about *diagnoses*.

## Workflow

### 1. Resolve the owning repo — enumerate, don't anchor
List ALL repos that could own the functionality before picking one (grep the feature across repos; check the service map if the workspace has one). Do not commit to the first keyword match — the same capability often lives in several repos, and anchoring on the first hit sends triage down the wrong codebase.

### 2. Ingest the failure artifact (Hard rule 1)
If an exception report / error log / failure notice exists, read it and match the exact error string to its source line before anything else.

### 3. Get a pinned, isolated checkout (Hard rule 4)
```bash
# one-time per repo: a bare mirror (object cache)
git clone --mirror <repo-url> <mirrors>/<repo>.git
# per incident: refresh, then an isolated worktree pinned to the deployed ref
git --git-dir=<mirrors>/<repo>.git remote update --prune
git --git-dir=<mirrors>/<repo>.git worktree add --detach <runs>/<incident>/<repo> <tag-or-main>
```
Pin to the deployed release tag if known; else latest `main`. **Record the exact ref/SHA** — the card must state it. Verify the deployed version matches (services deploying via image tags may run code that lags `main`).

### 4. Investigate (Hard rules 2 & 3)
Read whole functions top-to-bottom; trace each input variable to where it's produced and confirm validity at point of use; then `git log`/`git blame` the suspect area and recent commits near the incident time. If multiple paths fail, trace the shared dependency.

### 5. State the data lifecycle BEFORE the cause
In the card, briefly record: where the key inputs come from, whether they're valid at point of use, what the code does step-by-step — *then* the hypothesis with a confidence level.

### 6. Write the triage card (hypothesis)
Summary · Suspected root cause (+confidence) · Evidence (file:line, suspect commits) · Affected services/blast radius · What would confirm or kill this · Missing evidence/limits · Suggested next steps. Always state the ref triaged. Status stays **hypothesis** until human-confirmed.

### 7. Tear down the worktree
```bash
git --git-dir=<mirrors>/<repo>.git worktree remove -f <runs>/<incident>/<repo>
```

### 8. Do NOT write to confirmed incident memory
A hypothesis is not a confirmed cause. Graduate to the incident knowledge base only via the postmortem step, after a human confirms the actual fix.

## Postmortem (run once the incident is FIXED)

Inputs are **human-confirmed** — the fix commit/PR is provided, never inferred. Then:
1. **Explain why the fix works** — connect the change mechanically to the symptom. If you can't, suspect it masks rather than fixes.
2. **Score the hypothesis** — was triage correct / partial / wrong? (Feedback signal for method accuracy — record it even when "wrong.")
3. **Find sibling failure sites** — other call sites / tenants / paths with the same pattern. This is how one incident prevents the next.
4. **Record the confirmed cause** in the incident memory so future triage gets smarter.

## Workspace (when present)

If a triage workspace is set up (see the `triage-setup` script), it provides `<mirrors>` (bare clones), `<runs>` (per-incident worktrees), a service map (repo ownership), incident memory (confirmed causes, keyed by normalized error fingerprint), and a failure-artifact intake. Check the incident memory FIRST — a known fingerprint may already have the answer. Paths are workspace-local; read its README.

## Graceful degradation (portability limit)

This skill's *method* is portable to any IDE/tool. Its *execution* needs local prerequisites: VPN/repo access to create the mirror, and a filesystem for worktrees. If those are absent (e.g. a sandboxed assistant), say so explicitly, fall back to whatever code/history is reachable, and **flag that the checkout may not match the deployed ref** — do not present a sandbox-limited read as a confirmed finding.

## Guardrails

- Evidence before conclusion. If rules 1–3 aren't done, you don't have a root cause yet.
- Never triage the live working copy; never write guesses into confirmed memory; never infer a fix for a postmortem.
- Read-only analysis — propose fixes, don't apply them without confirmation.

## See Also
- `debugging` — dev/staging errors without a production incident.
- `/incident-response` — severity assessment, comms, escalation.
- `/postmortem` — close the loop on a fixed incident.
