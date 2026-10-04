# Work Log

A reverse-chronological record of changes. Read alongside `vision.md` (the intended game) and `codebase-research.md` (how the code maps to the vision) to understand the project's current state. Append a new dated section for each change.

## 2026-10-04 — Architecture deepening pass

Four refactors turning shallow modules into deep ones, plus a config migration. Aimed at testability and AI-navigability.

- **Extract `Bankroll` module** (`e0349ef`) — money (`balance` + `wager`) moved out of the copy-forwarded state machine into `src/state/bankroll.gd` (`place_wager` / `clear_wager` / `settle`). Created `GLOSSARY.md` (bankroll, wager, point, come-out roll).
- **Migrate project config to Godot 4.7** (`29467b0`) — `config/features` bumped `4.4` → `4.7`.
- **Extract `CrapsRules`** (`e928a30`) — come-out/point resolution moved into pure `CrapsRules.resolve(roll, point) -> Outcome` (`src/state/craps_rules.gd`).
- **State machine owns the roll** (`2f13428`) — `RollingState` triggers `quick_roll()`; `roll_complete(total, values)`; HUD renders via `roll_start`/`roll_complete`.
- **Presentation seam** (`d0e52d1`) — states talk to a 5-method `view` interface (`show_money`, `show_phase`, `set_betting_enabled`, `show_round_result`, `clear_results`). HUD is the production adapter; a headless `TestView` is the test adapter.

States now receive `view`, `bankroll`, and `dice_roller` through `setup()` rather than reaching into the HUD's node tree or copy-forwarding money/phase fields.

### Tests

Added a headless smoke-test suite in `test/` (no framework):

- `bankroll_smoke.gd` — money flows (place/clear/settle).
- `craps_rules_smoke.gd` — come-out and point resolution.
- `state_machine_smoke.gd` — full bet → roll → resolve flow with a `TestView` + `FakeDiceRoller`.

Run: `godot --headless --path . --script res://test/<file>.gd`
