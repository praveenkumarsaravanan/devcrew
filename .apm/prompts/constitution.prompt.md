# Constitution — Project Standards Setup

Set up a project's standards, governance, and persistent context. This is the primary entry point for creating `.project-context.md`.

## Steps

1. **Collect project identity:**
   - Ask for: project name, primary stack (language, framework, database), discipline (backend / frontend / fullstack).
   - Ask for: team size and any team naming conventions (branch prefixes, commit scopes).

2. **Detect platform configuration:**
   - Run the `project-detection` skill's platform detection steps (Steps 6–8) to determine:
     - **Task tracker:** Check available MCP servers (Atlassian → Jira, GitHub → GitHub Issues, etc.). Ask the user to choose.
     - **Execution mode:** Ask how implementation work should be executed (local / background / async / manual). Default to `local`.
     - **Git platform:** Detect from `git remote -v` (github / ghe / gitlab / bitbucket / azure-repos). Confirm with user.
   - If Jira is selected, ask for the project key.
   - If GitHub Issues is selected, confirm the repository.

3. **Generate `.project-context.md`:**
   - Use the `memory-management` skill (Operation 2: Write Context) to create the file at the project root.
   - Include all collected values in the structured frontmatter section.
   - Add empty sections for: Architecture Overview, Technology Decisions, Team Conventions, Notes.

4. **Generate `.memory.md`:**
   - Use the `memory-management` skill to create an empty memory file at the project root.
   - Pre-populate with domain section headers (Architecture Decisions, Auth & Security, Data Handling, Performance, Testing, Deployment, API Design, UI Patterns, General).
   - No entries yet — this file accumulates learnings over time.

5. **Validate active instructions:**
   - Verify that `coding-standards`, `security-baseline`, and `governance` instructions are active for the project.
   - If any are missing (e.g., the project hasn't run `apm install` yet), inform the user how to activate them.

6. **Present summary:**
   - Display all collected values in a clean table.
   - Confirm: "Project context saved to `.project-context.md`. Phase 0 will use these settings for all future runs. You can change any value by running `/constitution` again or editing the file directly."

## Notes

- This prompt is idempotent. Running it again updates existing values without losing manually-added notes.
- If `.project-context.md` already exists, load its values as defaults and let the user confirm or change them.
- The `project-bootstrap` skill calls this prompt as its first step when scaffolding a new project.
