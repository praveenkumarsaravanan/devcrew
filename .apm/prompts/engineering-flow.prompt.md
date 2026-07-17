# Engineering Flow

Run DevCrew Engineering Flow for the user's request.

1. Treat this prompt as the user-facing command for DevCrew Engineering Flow, implemented by the existing `team-workflow` skill.
2. Pass the user's request to `team-workflow` and preserve its right-sized lifecycle: detection, requirements when needed, architecture when needed, implementation, review, and tests.
3. Start with Phase 0. Classify task size, risk, and council depth.
4. If the user included `--deep`, `deep:`, "run deep council", or similar language, set council depth to `deep` unless the request is clearly a trivial quick fix. If it is trivial, explain why light mode is safer and ask before expanding.
5. Use the Council Chair behavior to explain active councils, skipped councils, trade-offs, checkpoints, and expected artifacts.
6. Continue into implementation when appropriate. If the user appears to want planning only, suggest `/convene-council` and ask before modifying files.
7. Keep quick fixes light: one Chair note, implementation, and lightweight review.

End each phase with the checkpoint required by DevCrew Engineering Flow.

