# Agent Operating Instructions

Before starting work:
1. Read `project-state/PROJECT_CONTEXT.md`, `project-state/ASSUMPTIONS.md`, `project-state/TODO.md`, and `project-state/DECISIONS.md`.
2. Check whether the requested task conflicts with any existing assumptions or decisions.
3. Prefer verifying assumptions from code before acting on them.

During work:
1. Keep changes small and focused.
2. Update tests when behavior changes.
3. Do not introduce new dependencies without documenting why.

Before finishing:
1. Update `project-state/PROJECT_CONTEXT.md` if the code structure or behavior changed.
2. Update `project-state/ASSUMPTIONS.md`:
   - remove assumptions that were verified or disproven
   - add new unresolved assumptions
3. Update `project-state/TODO.md` with remaining work.
4. Update `project-state/DECISIONS.md` for non-trivial architectural choices.
5. Run the test suite (Swift Testing, ⌘U in Xcode).
6. Keep only one README file and keep that updated with every change — must only include installing and running instructions and how to use the system.

Never treat `project-state/ASSUMPTIONS.md` as truth. Treat it as a list of hypotheses to verify against the code.
