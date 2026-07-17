---
name: fhir-review
description: Focused FHIR and HL7 Implementation Guide review using NPM packages and AI-ready bundles
---

# FHIR Review

Audit FHIR / Implementation Guide conformance **outside** the full Engineering Flow. Activates `fhir-health-interop`. User routing: `docs/fhir-health-interop.md`.

## Steps

1. Activate `fhir-health-interop`.
2. Confirm which IG and FHIR version apply. **Default for CRD / DTR / PAS work:** FHIR R4 (4.0.1) + US Core STU9 (`hl7.fhir.us.core#9.0.0`) + Da Vinci HRex + the workflow IG(s) in scope (CRD, PAS, DTR) + SMART App Launch when app-facing APIs are involved. Pin each Da Vinci IG version from its downloads page. If unknown or a different realm IG applies, ask before reviewing.
3. Load IG semantics for the confirmed IG and FHIR version:
   - **Local (preferred):** `.fhir/ai-bundles/<ig>/` — read `llms.txt`, then only the `markdown/` pages needed for this review.
   - **If local bundle is missing:** fetch from the **official HL7 URL** for that IG and FHIR version — **continue the review**; do not block on local setup.
     - Resolve the IG **canonical base** and **downloads** page (e.g. US Core STU9 → `https://hl7.org/fhir/us/core/`, downloads → `https://www.hl7.org/fhir/us/core/downloads.html`).
     - Fetch **`llms.txt`** at `<ig-base>/llms.txt` when published; use it to pick profile/binding pages.
     - Fetch only the **specific IG pages** required (StructureDefinition, profile, extension, search param) from HL7 — not the full site.
     - For base resource definitions, use the pinned FHIR release (e.g. R4 → `https://hl7.org/fhir/R4/`).
   - IG Markdown/HTML is for **semantics only**; conformance authority remains the **NPM package** (`package.tgz`) or FHIR validator output.
   - After review, optionally note that a **one-time** `apm run fhir-ai-bundle-setup <preset>` caches the bundle locally for faster follow-ups (re-run only to refresh from HL7).
4. Review StructureDefinitions, instances, CapabilityStatement, and search behavior against the **NPM package / validator**, using AI bundle Markdown only for IG semantics.
5. Activate `regulated-data-handling` when Patient, clinical observations, or exports are involved.
6. Activate `interoperability-contracts` when the change affects external consumers, version pins, or SMART/OAuth contracts.
7. Require validator output, example instances, and contract tests for material changes.

## Output

Return IG scope, conformance findings by severity, SMART/security gaps, regulated-data verdict, test gaps, and approve/request-changes recommendation.
