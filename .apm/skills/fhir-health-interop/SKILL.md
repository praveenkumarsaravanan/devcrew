---
name: fhir-health-interop
description: >
  FHIR and HL7 health interoperability development using official NPM packages,
  HL7 AI-ready Markdown bundles (ai.zip + llms.txt), SMART on FHIR, and profile
  validation. Use when building or reviewing FHIR APIs, Implementation Guides,
  StructureDefinitions, CapabilityStatements, or clinical data exchange.
---

# FHIR Health Interoperability

Guidance for **HL7 FHIR®** development aligned with HL7's open, AI-ready standards strategy. HL7 publishes computable NPM packages for validation and experimental **LLM-friendly Markdown bundles** (`ai.zip`, `llms.txt`) for AI-assisted implementation — see [HL7's AI force multiplier post](https://blog.hl7.org/embracing-ai-as-a-force-multiplier-for-health-data-standards).

## Trigger

Activate when the user or diff mentions:

- FHIR, HL7, SMART on FHIR, US Core, Da Vinci, CARIN, CDS Hooks, CDA, IPS
- **CRD**, **DTR**, **PAS**, **HRex**, prior authorization, coverage requirements discovery
- `StructureDefinition`, `CapabilityStatement`, `ImplementationGuide`, `OperationDefinition`
- FHIR REST (`Patient`, `Observation`, `Bundle`, `_search`, `_include`, `_revinclude`)
- FHIR NPM packages (`package.tgz`, `hl7.fhir.*`), IG Publisher, Simplifier, HAPI FHIR
- Clinical APIs, EHR integration, payer exchange, public health reporting
- HL7 **AI bundle**, `ai.zip`, or `llms.txt` for an Implementation Guide

Do **not** activate for generic REST APIs with no healthcare semantics — use `api-design` instead.

## Default stack: Da Vinci CRD / DTR / PAS

When work involves **Coverage Requirements Discovery (CRD)**, **Documentation Templates and Rules (DTR)**, **Prior Authorization Support (PAS)**, or the prior-auth chain **CRD → PAS → DTR**, map skills and reviews to this stack unless the user or project docs state otherwise:

| Layer | Pin | Role |
|-------|-----|------|
| Base FHIR | **R4 / 4.0.1** (`hl7.fhir.r4.core`) | Resource definitions, REST, search |
| US clinical floor | **US Core STU9 / 9.0.0** (`hl7.fhir.us.core#9.0.0`) | Minimum US clinical profiles |
| Da Vinci shared base | **HRex** (`hl7.fhir.us.davinci-hrex#<version>`) | Shared payer/provider profiles for CRD, PAS, DTR |
| Workflow IGs | **CRD**, **PAS**, **DTR** (pin each from its downloads page) | Coverage check → prior auth → payer questionnaires |
| App launch (when applicable) | **SMART App Launch 2.x** | OAuth/scopes for app-facing clinical APIs |

**Dependency order:** R4 → US Core → HRex → (CRD | PAS | DTR as implemented). Validate against each workflow IG's **full NPM dependency tree**, not US Core alone.

**US Core version note:** Published Da Vinci packages may still declare US Core 3.1.1 and/or 6.1.0. US Core STU9 is the project floor; document partner-tested US Core versions in CapabilityStatements when external interop is in scope.

**Also activate:** `interoperability-contracts` for version pins and external consumers; `regulated-data-handling` for Patient and clinical resources; SMART scope documentation when exposing user-facing APIs.

Canonical URLs and package ids: `references/hl7-ai-packages.md`.

## Skill vs `/fhir-review` — when to use which

| | `fhir-health-interop` (skill) | `/fhir-review` (prompt) |
|---|-------------------------------|-------------------------|
| **Type** | Skill — ongoing FHIR guidance | Slash command — focused review checklist |
| **Invoke** | Describe FHIR work in chat; auto-activates on FHIR/HL7 signals | Type `/fhir-review` in the command palette |
| **Use for** | Design, implementation, IG setup, validation strategy, explanations | Review existing resources/APIs/profiles before merge |
`/fhir-review` activates this skill for audits. There is **no** `/fhir-health-interop` command. User routing table: `docs/fhir-health-interop.md`.

## Hard Rules

1. **Validate against the NPM package, not Markdown alone.** AI bundles help comprehension; `package.tgz` (or validator output) is the conformance authority.
2. **Pin IG and FHIR versions.** Record package id, version, and FHIR release (R4, R4B, R5) in specs and CI.
3. **Treat clinical resources as regulated data.** Activate `regulated-data-handling` for Patient, Observation, DiagnosticReport, Condition, Medication, and similar resources — use synthetic fixtures only.
4. **Prefer official terminology bindings.** Do not invent local codes when a required ValueSet binding exists in the IG.
5. **Document SMART/OAuth scopes** when exposing user-facing clinical APIs.

## Workflow

### 1. Identify the Implementation Context

Record:

- **Realm IG** (e.g., US Core, IPS, national IG)
- **FHIR version** (R4 most common for US Core STU9)
- **Exchange pattern** (REST, subscriptions, Bulk Data, SMART app launch, CDex)
- **Consumer** (EHR, payer, app, public health, research)

### 2. Load HL7 AI-Ready Context

**Local first** — if `.fhir/ai-bundles/<ig>/` exists, read `llms.txt`, then only needed `markdown/` pages.

**If local bundle is missing** — fetch from the **official HL7 URL** for the pinned IG and FHIR version (do not block work on `fhir-ai-bundle-setup`):

| Need | HL7 source |
|------|------------|
| IG index / LLM manifest | `<ig-base>/llms.txt` (when published) |
| Downloads, NPM package, LLM-Ready View | `<ig-base>/downloads.html` or IG-specific downloads URL |
| Profile, extension, search param pages | Canonical IG site under `<ig-base>/` |
| Base FHIR resources | `https://hl7.org/fhir/R4/` (or R4B / R5 as pinned) |

Examples: US Core → `https://hl7.org/fhir/us/core/`; US Core downloads → [downloads](https://www.hl7.org/fhir/us/core/downloads.html).

Use HL7-fetched content for **IG semantics only**. Conformance authority: NPM package or validator. See `references/hl7-ai-packages.md`.

**Optional cache for later sessions** (not required per review):

```sh
apm run fhir-ai-bundle-setup us-core
```

Re-run setup only to refresh from HL7. Layout: `references/hl7-ai-packages.md`.

### 3. Design or Review FHIR Resources

**REST API surface:**

- Resource types and interactions (`read`, `search-type`, `create`, `update`, `patch`, `delete`, `history`)
- Search parameters — use IG-defined params where required
- `_summary`, `_elements`, pagination (`_count`, `next` links)
- Error format: `OperationOutcome` with meaningful `issue.diagnostics` (no PHI in diagnostics text)

**Profiles and extensions:**

- Declare `meta.profile` for IG-conformant instances
- Use US Core (or applicable) profiles — do not redefine core elements without justification
- Extensions only from the IG or registered extension registry

**CapabilityStatement:**

- Must reflect what the server actually implements
- Include supported profiles, search params, and security (SMART/OAuth URIs)

### 4. Validate and Test

- Run resources through the [FHIR Validator](https://confluence.hl7.org/display/FHIR/Using+the+FHIR+Validator) or project CI with the pinned IG package
- Include example instances for each supported profile
- Contract tests: request/response round-trips, search param behavior, `_include` graphs
- For breaking IG upgrades: document consumer migration and parallel version support

Activate `interoperability-contracts` when the change affects external consumers, version pins, or cross-team FHIR API contracts.

### 5. Security and Operations

- SMART on FHIR: least-privilege scopes, token lifetimes, audience validation
- Audit events for clinical read/export where required
- Rate limits and bulk export job monitoring for large data pulls
- No PHI in logs, metrics labels, or AI prompts

## Relationship to Other Skills

| Skill | When |
|-------|------|
| `interoperability-contracts` | Versioning, deprecation, consumer migration, contract tests across teams |
| `regulated-data-handling` | PHI/PII classification, synthetic data, audit, retention |
| `api-design` | General REST patterns — FHIR-specific rules take precedence here |
| `typescript-node-standards` | Node FHIR servers, workers, subscription consumers |
| `data-ingestion` | FHIR Bulk Data, NDJSON feeds, replay/reconciliation |

## Output (reviews and design)

Return:

- IG + FHIR version in scope
- Whether AI bundle and NPM package are pinned
- Profile/conformance findings by severity
- SMART/security gaps
- Regulated-data handling verdict
- Required validator and contract tests
- Recommendation: approve, request changes, or insufficient IG context (fetch from HL7 or validator before concluding)

## References

- `references/hl7-ai-packages.md` — AI bundle catalog and workspace layout
- [HL7 FHIR specification](https://hl7.org/fhir/)
- [US Core downloads (NPM + LLM-Ready View)](https://www.hl7.org/fhir/us/core/downloads.html)
