---
name: documentation
description: >
  Write and maintain project documentation — READMEs, guides, runbooks,
  ADRs, and onboarding docs. Enforces clarity, audience awareness, and
  minimal repetition. Use when creating, restructuring, or reviewing
  any documentation file.
---

# Documentation

## Trigger

Activate this skill when:

- The user asks to create, update, or restructure a README
- The user asks to write or review documentation of any kind (guides, runbooks, ADRs, onboarding docs)
- The user asks to document an API, feature, process, or architecture decision
- A new project is being scaffolded and needs initial documentation
- The user asks to simplify, shorten, or clean up existing docs

## Principles

Every decision in this skill flows from five rules:

1. **Audience first** — identify who will read this before writing a single line. Different readers need different sections.
2. **One fact, one place** — never state the same information twice. Repetition causes drift when one copy is updated and the other isn't.
3. **Scannable over readable** — use headings, tables, and code blocks. Walls of prose lose readers. A doc that isn't scanned is a doc that isn't read.
4. **Concrete over abstract** — show a working command or code snippet instead of describing what someone "should" do. Copy-paste-ready examples beat paragraphs of explanation.
5. **Maintain ruthlessly** — every section must earn its place. If a section is stale, wrong, or adds no value, remove it. Shorter docs are more accurate docs.

## Workflow

### 1. Identify the Audience

Before writing, determine who will read this document. Common audiences:

| Audience | What they need | Tone |
| --- | --- | --- |
| **New users / consumers** | Install steps, quick start, working examples | Direct, zero assumed knowledge |
| **Contributors** | Dev setup, conventions, PR process, how to test | Concise, assumes basic tooling familiarity |
| **Operators / SREs** | Runbooks, config reference, troubleshooting | Precise, scannable under pressure |
| **Decision-makers** | ADRs, trade-off summaries, migration plans | Structured, options with pros/cons |

If a single document serves multiple audiences, use clearly labeled sections — do not interleave content for different readers.

### 2. Choose the Right Format

| Document type | When to use | Structure |
| --- | --- | --- |
| **README** | Every repo's front door | About → Getting Started → Contributing → Reference |
| **Guide / Tutorial** | Walk through a multi-step process | Prerequisites → Steps → Verify → Troubleshooting |
| **Runbook** | Operational procedure for incidents | Symptoms → Diagnosis → Resolution → Escalation |
| **ADR** | Record an architecture decision | Context → Decision → Consequences → Status |
| **API Reference** | Document endpoints or interfaces | Endpoint → Parameters → Request/Response → Errors |
| **Changelog** | Track what changed per release | Version → Date → Added/Changed/Fixed/Removed |

### 3. Draft the Content

Follow these rules while writing:

**Structure:**
- Lead with a one-line summary that tells the reader what this is and why it exists
- Use a table of contents for documents with 4+ sections
- Keep heading hierarchy clean — never skip levels (h2 → h4)
- One topic per section. If a section covers two things, split it.

**Language:**
- Use imperative mood for instructions: "Run the setup script", not "You should run the setup script"
- Write in present tense: "APM deploys files to...", not "APM will deploy files to..."
- Avoid weasel words: "simply", "just", "easy", "straightforward" — these are subjective and unhelpful to someone who is stuck
- Define acronyms on first use. After that, use the acronym alone.
- Prefer short sentences. If a sentence has more than one comma, consider splitting it.

**Code blocks:**
- Every installation, configuration, or usage step must include a copy-paste-ready command or snippet
- Always specify the language tag on fenced code blocks (`sh`, `yaml`, `json`, etc.)
- Show realistic values, not placeholders like `<your-value-here>` — if a value is user-specific, use an obviously fake but structurally valid example (e.g., `ghp_abc123...`)
- Show expected output when it helps the reader verify they're on track

**Tables over lists when:**
- Comparing options (columns = criteria, rows = choices)
- Documenting parameters, env vars, or config fields
- Showing feature/compatibility matrices

**Links:**
- Link to external resources rather than duplicating their content
- Use descriptive link text: `[generate a PAT](https://...)`, not `[click here](https://...)`

### 4. Eliminate Repetition

After drafting, scan for information that appears in more than one place:

- If two sections say the same thing, keep the one closest to where the reader needs it and remove the other
- If a fact must be referenced from multiple places, state it once in a canonical location and link to it
- Watch for these common duplication traps:
  - Prerequisites repeated in both setup and usage sections
  - File paths listed in both a tree diagram and a table
  - The same command shown in "getting started" and "reference" sections

### 5. Review Checklist

Before finalizing, verify:

| Check | Question |
| --- | --- |
| **Audience** | Is it clear who this document is for? |
| **Completeness** | Can a reader accomplish the goal using only this document plus linked resources? |
| **No repetition** | Is every fact stated exactly once? |
| **Copy-paste ready** | Can every command/snippet be copied and run without modification (or with only obvious substitutions)? |
| **Scannable** | Can a reader find what they need in under 30 seconds using headings and the ToC? |
| **No stale content** | Is every section current? Are there references to removed features, old paths, or deprecated tools? |
| **Consistent terminology** | Is the same thing called the same name throughout? (e.g., don't alternate between "token" and "key" for the same credential) |
| **No weasel words** | Removed "simply", "just", "easy", "obviously", "straightforward"? |

### 6. Maintain Existing Docs

When editing an existing document rather than creating one from scratch:

1. **Read the entire document first.** Understand the existing structure before changing anything.
2. **Preserve the author's voice** unless the doc is being fully rewritten. Match the tone and style of surrounding sections.
3. **Check cross-references.** If you rename a section, update the ToC and any internal links.
4. **Remove what's wrong, not just add what's right.** If new content makes an existing section redundant, delete the old section.
5. **Verify after editing.** Re-read the full document to catch contradictions introduced by the edit.

## Guardrails

- **Never add documentation "just in case."** Every section must serve a specific reader with a specific goal. If you can't name the audience, don't write the section.
- **Never duplicate information across sections.** If you find yourself copying text, stop — extract it to one location and reference it.
- **Never use comments to narrate what the code does.** In code examples within docs, only comment on non-obvious behavior.
- **Never leave placeholder sections.** "TBD", "TODO", and empty sections signal an unfinished doc and erode trust. Either write it or omit it.
- **Never assume the reader's environment.** State the OS, tool versions, and prerequisites explicitly. "Works on my machine" is not documentation.
- **Always include a way to verify.** After any install or config step, show how the reader can confirm it worked.
