# HL7 AI-Ready FHIR Packages

Reference for DevCrew's `fhir-health-interop` skill. **User routing (build vs review, setup):** [docs/fhir-health-interop.md](../../../../docs/fhir-health-interop.md).

HL7 publishes **LLM-friendly Markdown bundles** alongside traditional FHIR NPM packages so AI assistants can reason about Implementation Guides without ingesting verbose HTML.

Source: [Embracing AI as a Force Multiplier for Health Data Standards](https://blog.hl7.org/embracing-ai-as-a-force-multiplier-for-health-data-standards) (HL7 International, Jun 2026).

## What HL7 Publishes

| Artifact | Purpose | Use in DevCrew |
|----------|---------|----------------|
| **NPM package** (`package.tgz`) | Machine-readable profiles, value sets, extensions — **authoritative for validation** | CI validation, `$validate`, IG Publisher, Simplifier |
| **`ai.zip`** | Markdown conversion of IG HTML pages — token-efficient for LLM context | Load into workspace via `apm run fhir-ai-bundle-setup` |
| **`llms.txt`** | Machine-readable index of Markdown files in the bundle | Route the agent to the right profile/page |
| **JSON/XML definitions** | Computable resource definitions | Codegen, validator, structure maps |
| **Reference implementations** | HAPI FHIR, FHIR server samples on GitHub | Conformance testing, worked examples |

**Rule:** Use `ai.zip` for **understanding and design**; use the **NPM package** for **validation and build artifacts**. Do not treat Markdown alone as the conformance source of truth.

## Known AI Bundle Endpoints

Check each IG's **Downloads** page for `LLM-Ready View` — availability expands over time.

| Implementation Guide | AI bundle (verify on downloads page) | NPM package id (example) |
|---------------------|--------------------------------------|--------------------------|
| US Core STU9 | `https://hl7.org/fhir/us/core/ai.zip` | `hl7.fhir.us.core` |
| US Core downloads | [US Core downloads](https://www.hl7.org/fhir/us/core/downloads.html) | See `package.tgz` on same page |
| SMART Base | GitHub release `ai.zip` asset | `smart.who.int.base` |
| Base FHIR R4 | Use spec site + NPM `hl7.fhir.r4.core` | `hl7.org/fhir/R4/` |

When an IG provides `llms.txt`, download it alongside `ai.zip` from the same downloads section.

## Default stack: Da Vinci CRD / DTR / PAS

When `fhir-health-interop` or `/fhir-review` is triggered by **CRD**, **DTR**, **PAS**, or **HRex** work, assume this stack unless the project pins otherwise:

| Layer | Package / version | Canonical base |
|-------|-------------------|----------------|
| FHIR R4 | `hl7.fhir.r4.core` @ 4.0.1 | `https://hl7.org/fhir/R4/` |
| US Core STU9 | `hl7.fhir.us.core#9.0.0` | `https://hl7.org/fhir/us/core/` |
| Da Vinci HRex | `hl7.fhir.us.davinci-hrex#<version>` | `https://hl7.org/fhir/us/davinci-hrex/` |
| Da Vinci CRD | `hl7.fhir.us.davinci-crd#<version>` | `https://hl7.org/fhir/us/davinci-crd/` |
| Da Vinci PAS | `hl7.fhir.us.davinci-pas#<version>` | `https://hl7.org/fhir/us/davinci-pas/` |
| Da Vinci DTR | `hl7.fhir.us.davinci-dtr#<version>` | `https://hl7.org/fhir/us/davinci-dtr/` |
| SMART App Launch (when app-facing) | `smart.who.int.fhir#<version>` | `http://hl7.org/fhir/smart-app-launch/` |

Pin `<version>` from each IG's **Downloads** page. Validate with the workflow IG's full NPM dependency tree (HRex + CRD/PAS/DTR), not US Core alone. DTR also commonly depends on **SDC** (Structured Data Capture).

**Workflow chain:** CRD (point-of-care coverage check) → PAS (prior auth submission) → DTR (payer questionnaires / documentation templates).

## Workspace Layout (after `fhir-ai-bundle-setup`)

```
.fhir/
  ai-bundles/
    us-core/           # example preset
      llms.txt         # manifest — read this first
      markdown/        # extracted IG pages (what agents actually use)
  .gitignore           # ignores markdown/ by default (large, regenerable)
```

The setup script downloads `ai.zip` only long enough to extract into `markdown/`, then deletes the zip. **You do not need `ai.zip` on disk** after setup — only `llms.txt` and `markdown/`.

Run `apm run fhir-ai-bundle-setup <preset>` **once** per IG when starting FHIR work. **Re-run only to refresh** from HL7 when the IG version changes or you need updated ballot content — not on every dev session.

Add `.fhir/ai-bundles/` to `.gitignore` when bundles are large; document the setup command in the project README instead.

## Agent Usage Pattern

1. **Before designing or reviewing FHIR resources**, check whether a local AI bundle exists under `.fhir/ai-bundles/<ig>/`.
2. **If local bundle exists:** read `llms.txt` first, then open only the Markdown files needed.
3. **If local bundle is missing:** fetch IG semantics from the **official HL7 URL** for the pinned IG and FHIR version — `llms.txt`, downloads page, and specific profile/structure pages under the IG canonical base; use base FHIR spec URL for core resources (e.g. `https://hl7.org/fhir/R4/`). **Do not stop** the task to run setup first.
4. **Cross-check** StructureDefinitions, CapabilityStatements, and examples against the NPM package or official validator.
5. **PHI/PII:** activate `regulated-data-handling` — FHIR Patient, Observation, DiagnosticReport, and related resources often carry regulated data.
6. **Optional:** suggest one-time `apm run fhir-ai-bundle-setup <preset>` after the session to cache locally (re-run only to refresh from HL7).

## FHIR Development Checklist (summary)

- [ ] IG version and NPM package pinned in project docs or `package.json` / `fhir-settings.json`
- [ ] AI bundle fetched for the active IG (if available)
- [ ] Profiles validated with official FHIR validator or IG tooling
- [ ] SMART on FHIR / OAuth scopes documented when exposing clinical APIs
- [ ] US Core (or applicable realm IG) profiles used for US healthcare exchange
- [ ] Terminology bindings verified (ValueSet, CodeSystem)
- [ ] Examples pass `$validate` against the target IG
- [ ] No PHI in logs, prompts, fixtures, or test screenshots

## Licensing

HL7 publishes FHIR platform specifications under **CC0** (public domain dedication). The **FHIR®** trademark is governed by [HL7 trademark policy](https://www.hl7.org/legal/trademark.html) — use the mark correctly in product descriptions, not to claim false conformance.

## See Also

- [FHIR specification](https://hl7.org/fhir/)
- [US Core IG](https://hl7.org/fhir/us/core/)
- [SMART on FHIR](http://hl7.org/fhir/smart-app-launch/)
- DevCrew skills: `fhir-health-interop`, `interoperability-contracts`, `regulated-data-handling`
