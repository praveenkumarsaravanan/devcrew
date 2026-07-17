# Canonical Spec Format

Every `.spec.md` file follows this structure. Sections marked *(conditional)* may be omitted when they do not apply — add a brief note explaining why (e.g., "N/A — no persisted data").

---

## Required Sections

### 1. Problem Statement

One to three paragraphs describing:

- What problem exists today.
- Who is affected (users, teams, systems).
- Why it needs to be solved now.

### 2. Scope

| In scope | Out of scope |
|----------|--------------|
| Clearly list what this feature covers | Explicitly list what it does NOT cover |

Be specific. Ambiguous scope is the top cause of spec rework.

### 3. Requirements

A numbered table of testable requirements.

| ID | Description | Acceptance Criteria | Priority |
|----|-------------|---------------------|----------|
| REQ-001 | [What the system must do] | [Observable, testable condition that proves the requirement is met] | Must / Should / Could |

**Rules:**

1. Every requirement gets a unique ID (`REQ-NNN`).
2. Acceptance criteria must be verifiable by a test — manual or automated.
3. Use MoSCoW priorities: **Must** (launch blocker), **Should** (expected), **Could** (nice-to-have).

**Example:**

| ID | Description | Acceptance Criteria | Priority |
|----|-------------|---------------------|----------|
| REQ-001 | Users can reset their password via email | Given a registered email, when the user requests a reset, then they receive a reset link within 60 seconds that expires after 24 hours | Must |

### 4. API Contracts *(conditional)*

Include when the feature exposes or consumes an API. Define:

- Method, path, and description for each endpoint.
- Request and response schemas with types.
- Authentication and authorization requirements.

Omit with note when the feature has no API surface.

### 5. Data Model *(conditional)*

Include when the feature introduces or modifies persisted data. Define:

- Entities and their fields (name, type, constraints).
- Relationships between entities.
- Indexes or unique constraints.

Omit with note when no data model changes are needed.

### 6. Error Scenarios

| Trigger | Expected Behavior | HTTP Status / Error Code |
|---------|-------------------|--------------------------|
| [Condition that causes the error] | [What the system does — message, retry, fallback] | [Status code or internal error code] |

Document at minimum: invalid input, unauthorized access, resource not found, and downstream failure.

### 7. Validation Criteria

A checklist of conditions that must be true for the feature to be considered complete:

- [ ] All `Must` requirements pass acceptance criteria
- [ ] Error scenarios return correct status codes and messages
- [ ] Performance targets are met (if defined in requirements)
- [ ] No regressions in existing test suites

### 8. Dependencies

| Dependency | Type | Status | Owner |
|------------|------|--------|-------|
| [System, service, team, or data source] | Internal / External | Available / Pending / Blocked | [Team or person] |

Write "None" if there are no dependencies — do not leave this section empty.

### 9. Handoff Checklist

Items the architecture and implementation phases need before they begin:

- [ ] Spec reviewed and approved by stakeholder
- [ ] Open questions resolved (none remain in this document)
- [ ] Dependencies confirmed available or timeline agreed
- [ ] API contracts reviewed by consuming teams (if applicable)
- [ ] Data model reviewed by DBA or data team (if applicable)

---

## Section Omission Rules

| Section | Can omit when |
|---------|---------------|
| API Contracts | Feature has no API surface (pure backend logic, migration, etc.) |
| Data Model | Feature does not change persisted data |
| Error Scenarios | Never — always required |
| Dependencies | Never — write "None" if there are no dependencies |

All other sections are always required.
