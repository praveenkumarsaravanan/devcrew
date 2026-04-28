---
id: SO-005
dimension: skill-output
skill: commit-message
name: Generate commit message for a multi-file change
pass_threshold: 0.70
scoring: skill-output-judge
---

# SO-005: Generate Commit Message for Multi-File Change

## Task

> I've added input validation to the user registration endpoint.
> Changed files: UserController.java, UserService.java, UserValidator.java (new),
> UserControllerTest.java, and updated the OpenAPI spec in api.yml.

Activate the `commit-message` skill to generate a commit message.

## Expected Behavior

1. Uses Conventional Commits format (`feat:`, `fix:`, `chore:`, etc.).
2. Correctly identifies this as a `feat` (new validation capability).
3. Subject line is ≤72 characters.
4. Body explains what changed and why.
5. References files or scope appropriately.

## Scoring

| Criterion | Weight | Pass |
|-----------|--------|------|
| Conventional Commits format | 25% | Starts with valid type prefix |
| Correct type classification (feat) | 20% | Not `fix` or `chore` — this is new functionality |
| Subject line ≤72 characters | 15% | Character count ≤72 |
| Body explains the change | 25% | More than just the subject; mentions validation |
| Would pass commitlint | 15% | Valid format that a standard commitlint config would accept |

**Critical failure:** Generates a message that doesn't follow Conventional Commits at all.
