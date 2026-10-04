# 01: Reorganize HUD into three groups

**What to build:** The single-column HUD is rearranged into three groups, ordered by when the player needs them: **Status** (bankroll + phase) at the top, **Action** (current bet + bet buttons + roll) in the middle, **Readout** (dice + dice result + round result) at the bottom. This is a pure re-grouping — same signals, same state flow, no behavior change.

**Blocked by:** None (can start immediately)

**Status:** resolved

- [x] HUD scene has three container groups (Status / Action / Readout) in a single column, top to bottom.
- [x] Bankroll and Phase labels live in Status; Current Bet, bet buttons, and Roll live in Action; dice viewport, dice result, and round result live in Readout.
- [x] All `hud.gd` node-path references updated to the new structure.
- [x] Existing behavior unchanged: betting, rolling, phase display, and win/lose text still work (headless load + `state_machine_smoke.gd` still green).

## Comments

- Restructured `main.tscn`: `Status` (BoxContainer, top) holds Bankroll + Phase; `Action` (BoxContainer, centered) holds Current Bet + BetButtons + RollButton + Timer; `Readout` (full-rect Control) holds the dice SubViewportContainer (still `top_level`, same position) + `Results`.
- Updated `hud.gd` node paths. Verified: headless load clean, all three smoke tests pass. Exact spacing needs a play-test pass (as expected for a visual change).
