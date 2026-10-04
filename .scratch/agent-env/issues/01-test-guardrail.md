# 01: Automated test script + guardrail

**What to build:** A single command that runs all headless smoke tests and a guardrail that runs it automatically. Today verification is a manual loop over `test/*.gd` one file at a time, and there is no CI or pre-commit hook (AGENTS.md states "No lint or CI" as a fact, not a fix). This is the retro's top finding.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] A `test/run_all.sh` script runs every `test/*.gd` headlessly (via `godot --headless --path . --script res://test/<file>.gd`) and exits non-zero if any test fails.
- [ ] AGENTS.md "Commands" section documents the one-command run (e.g. `npm run test` or `./test/run_all.sh`).
- [ ] A pre-commit hook runs the test script (either `.git/hooks/pre-commit` or a tracked `hooks/` dir wired via `git config core.hooksPath`).

## Notes

- The `godot` binary on macOS lives at `/Applications/Godot.app/Contents/MacOS/Godot` (already documented in AGENTS.md); the script should fall back to `godot` on `PATH`.
- Tests are headless `SceneTree` scripts with no framework (see `test/*.gd`); "pass" = exits `0`, "fail" = exits `1`.
