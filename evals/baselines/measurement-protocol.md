# Before/After Measurement Protocol

Measures the delta in quality, speed, and consistency when using DevCrew vs a bare AI assistant.

## Setup

### Test project

Use a real or representative project with:
- At least one backend service with database access
- At least one frontend component
- Existing test infrastructure (even if sparse)
- A git repository with commit history

### Control condition (Without DevCrew)

- Same project, same AI model (Cursor/Copilot/Claude)
- No `.apm/` directory, no agents, no skills, no instructions
- Developer uses the AI assistant with default behavior
- Developer provides context manually as needed

### Treatment condition (With DevCrew)

- Same project, same AI model
- DevCrew installed via `apm install`
- `.project-context.md` and `.memory.md` initialized
- Developer activates team-workflow for each task

### Task set

Use the same 5 tasks for both conditions. Recommended:

| # | Task | Expected size |
|---|------|---------------|
| 1 | Fix a specific bug (provide real bug) | Quick fix |
| 2 | Add input validation to an existing form | Standard change |
| 3 | Add a new API endpoint following existing patterns | Standard change |
| 4 | Build a new feature requiring design decisions | Full feature |
| 5 | Review a file with known security issues | Review |

## Metrics

### A. Time to completion

Measure wall-clock time from task start to "ready for PR" for each task.

```
Task 1: Without [__] min | With DevCrew [__] min | Delta [__]%
Task 2: Without [__] min | With DevCrew [__] min | Delta [__]%
Task 3: Without [__] min | With DevCrew [__] min | Delta [__]%
Task 4: Without [__] min | With DevCrew [__] min | Delta [__]%
Task 5: Without [__] min | With DevCrew [__] min | Delta [__]%
```

**Note:** DevCrew may be slower for quick fixes (process overhead) and faster for full features (structured approach avoids rework). Measure both.

### B. Quality score

For each task output, apply the relevant LLM-as-judge rubric:

| Dimension | Without | With DevCrew | Judge used |
|-----------|---------|-------------|------------|
| Requirements completeness | /5 | /5 | requirements-judge |
| Security issues caught | /5 | /5 | review-quality-judge |
| Test coverage adequacy | /5 | /5 | (manual assessment) |
| Code follows project patterns | /5 | /5 | (manual assessment) |

### C. Interaction count

Count the number of user messages/interactions needed to complete each task.

```
Task 1: Without [__] interactions | With DevCrew [__] interactions
Task 2: Without [__] interactions | With DevCrew [__] interactions
...
```

Lower is better for routine tasks. Higher may be expected for full features (quality gates).

### D. Rework rate

Count the number of times the developer had to ask the agent to redo or fix something.

```
Task 1: Without [__] reworks | With DevCrew [__] reworks
...
```

### E. Context re-explanation

Count how many times the developer had to re-explain project context (tracker, conventions, stack, prior decisions).

```
Session 1: Without [__] re-explanations | With DevCrew [__] re-explanations
Session 2: Without [__] re-explanations | With DevCrew [__] re-explanations
Session 3: Without [__] re-explanations | With DevCrew [__] re-explanations
```

This should be near-zero with DevCrew after Session 1 (context is persisted).

## Reporting

### Summary table

```
| Metric                  | Without | With DevCrew | Delta   |
|-------------------------|---------|-------------|---------|
| Avg time to completion  |   min   |    min      |   %     |
| Avg quality score       |   /5    |    /5       |  +/-    |
| Avg interactions        |         |             |   %     |
| Avg reworks             |         |             |   %     |
| Context re-explanations |         |             |   %     |
```

### Interpretation

| Delta | Meaning |
|-------|---------|
| Quality +1.0 or more | Significant improvement — DevCrew adds measurable value |
| Quality +0.5 to +1.0 | Moderate improvement — worth the process overhead |
| Quality -0.5 to +0.5 | Neutral — DevCrew adds process but not quality |
| Quality below -0.5 | Regression — investigate whether process is interfering |
| Time +20% on quick fixes | Expected — process overhead on small tasks |
| Time -20% on full features | Expected — structured approach prevents rework |
| Context re-explanations near 0 | Memory working as designed |

## Execution order

1. Run all 5 tasks **without** DevCrew first (control)
2. Wait at least 1 day (avoid learning effects)
3. Run all 5 tasks **with** DevCrew (treatment)
4. Score all outputs using judges
5. Fill in the summary table
6. Write findings in `evals/report-template.md`
