# FHIR / HL7 Health Interoperability

DevCrew support for [HL7's AI-ready FHIR strategy](https://blog.hl7.org/embracing-ai-as-a-force-multiplier-for-health-data-standards): CC0 specs, NPM packages for validation, and LLM-ready Markdown bundles (`llms.txt` + `markdown/`).

**There is no `/fhir-health-interop` slash command** — that is the **skill** name. The review command is **`/fhir-review`**.

## When to use what

| You want to… | Use | How |
|--------------|-----|-----|
| Build a FHIR API, resource, profile, or SMART integration | `fhir-health-interop` | Describe the task in chat; skill may auto-activate on FHIR/HL7 signals |
| Review FHIR conformance before merge | `/fhir-review` | Slash command — activates the skill + structured review checklist |
| Fetch HL7 LLM-ready IG pages (first time) | `fhir-ai-bundle-setup` | `apm run fhir-ai-bundle-setup us-core` → `.fhir/ai-bundles/<ig>/` |
| Full feature lifecycle with FHIR work | `/engineering-flow` | FHIR skill applies when the task involves clinical interoperability |
| Generic REST (no clinical semantics) | `api-design` / `/contract-review` | FHIR-specific rules do not apply |

**Rule of thumb:** build or learn → **`fhir-health-interop`**. Audit before merge → **`/fhir-review`**.

## Default stack: Da Vinci CRD / DTR / PAS

When work involves **CRD**, **DTR**, **PAS**, or the prior-auth chain **CRD → PAS → DTR**, `fhir-health-interop` and `/fhir-review` map to:

| Layer | Pin |
|-------|-----|
| Base FHIR | **R4 / 4.0.1** (`hl7.fhir.r4.core`) |
| US clinical floor | **US Core STU9 / 9.0.0** (`hl7.fhir.us.core#9.0.0`) |
| Da Vinci shared base | **HRex** — pin version from [HRex downloads](https://hl7.org/fhir/us/davinci-hrex/downloads.html) |
| Workflow IGs | **CRD**, **PAS**, **DTR** — pin each from its downloads page |
| App launch (when applicable) | **SMART App Launch 2.x** |

Validate against each workflow IG's full NPM dependency tree, not US Core alone. Package ids and URLs: `.apm/skills/fhir-health-interop/references/hl7-ai-packages.md`.

## AI bundle setup (once per IG)

```sh
apm run fhir-ai-bundle-setup us-core
```

- **Run once** when starting FHIR work on a project (or when adding a new IG).
- After setup, use local **`llms.txt`** (index) and **`markdown/`** (pages) — no zip file needed.
- **Re-run only to refresh** from HL7: new IG version, updated ballot, or intentional re-download.
- **No local bundle?** `/fhir-review` and `fhir-health-interop` fetch IG semantics from the official HL7 URL for the pinned IG/FHIR version — setup is optional caching, not a prerequisite.

US Core preset: [US Core LLM-Ready View](https://www.hl7.org/fhir/us/core/downloads.html).

**Conformance:** NPM package (`package.tgz`) or FHIR validator = authority. AI bundle Markdown = IG semantics only.

## Primitives

| Piece | Location |
|-------|----------|
| Skill (workflow + rules) | `.apm/skills/fhir-health-interop/SKILL.md` |
| HL7 packages catalog + checklist | `.apm/skills/fhir-health-interop/references/hl7-ai-packages.md` |
| Review prompt | `.apm/prompts/fhir-review.prompt.md` |
| Setup script | `scripts/fhir-ai-bundle-setup.sh` |

Doc placement for this repo: [documentation-layering.md](./documentation-layering.md).

## See also

- [Documentation layering](documentation-layering.md) — repo-wide doc placement
- [DevCrew Index](devcrew-index.md) — full primitive catalog
- [Engineering Flow](engineering-flow.md) — lifecycle routing
