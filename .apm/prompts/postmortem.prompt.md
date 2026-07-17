---
name: postmortem
description: Close the loop on a fixed incident — verify the fix, score the triage, find sibling bugs, record confirmed cause
---

# Postmortem

Run a postmortem on a **fixed** incident. Activate the `triage` skill (postmortem section).

Arguments: `<incident_no> <service-repo> <fix-commit-or-PR>` — the fix is a **required, human-confirmed input. Never infer it from history.**

1. **Get the fixed code** in a worktree (never the working copy); read the fix diff (`git show <commit>`).
2. **Explain why the fix works** — connect the change mechanically to the symptom. If you can't, flag that it may mask rather than fix.
3. **Score the triage hypothesis** — correct / partial / wrong, and why (record even when wrong — it's the method's feedback signal).
4. **Find sibling failure sites** — other call sites / tenants / paths with the same pattern; list with file:line. This is the highest-value output.
5. **Record the confirmed root cause** in the incident knowledge base (normalized fingerprint) so future triage gets smarter.
6. **Tear down** the worktree.

Read-only analysis — recommend follow-up tickets for sibling risks; do not apply changes.
