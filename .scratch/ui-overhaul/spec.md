# UI Overhaul: HUD Grouping + Delta Indicators

## Problem Statement

The HUD is a single flat column: Bankroll, Wager, and Phase are stacked at the top, then bet buttons, roll button, dice, and results — with no grouping that reflects when the player needs each piece. Worse, when money changes the only feedback is a red/green flash on the Wager label, so the player can't tell what changed or by how much (a win, a loss, a bet, a clear all look alike). Timings are hard-coded (a 0.25s `Timer`) and not tunable.

## Solution

Reorganize the single-column HUD into three groups, ordered by when the player interacts with or tracks them: **Status** (bankroll + phase), **Action** (wager + bet buttons, roll), **Readout** (dice, dice result, round result). Replace the flash with **delta** indicators — small green/red `+$N` / `-$N` chips next to the number that changed — and make the bankroll read as a clean score by keeping a winning wager on the table (ADR-0001). Move all timing into a single inspector-tunable resource.

## User Stories

1. As a player, I want my bankroll shown prominently at the top as my score, so I always know where I stand.
2. As a player, I want the current phase and point shown near my bankroll, so I can read the game state at a glance.
3. As a player, I want the wager and the bet buttons grouped together, so I place and review my wager in one place.
4. As a player, I want the roll button next to the dice, so the action I take is next to what it affects.
5. As a player, I want the dice result shown directly under the dice, so I connect the roll to the numbers immediately.
6. As a player, when I place a bet I want to see `-$X` next to my bankroll and `+$X` next to my wager, so I see my money move onto the table.
7. As a player, when I clear a bet I want to see `+$X` next to my bankroll and `-$X` next to my wager, so I see my money return.
8. As a player, when I win I want a green `+$profit` next to my bankroll, so I see exactly what I gained.
9. As a player, when I lose I want a red `-$wager` next to my wager, so I see exactly what I lost.
10. As a player, I want my winning wager to stay on the table, so I can keep rolling without re-betting.
11. As a player, I want to add to a wager that is already on the table, so I can raise my stake between rounds.
12. As a player, I want the delta indicators to animate in (count to their value) and then fade out after about a second, so they give feedback without cluttering the screen.
13. As a player, I want to see "You Win!" or "You Lose!" as text, so I know the outcome separately from the money movement.
14. As a developer, I want every timing value in one place, so I can tune the game's feel without touching logic.

## Implementation Decisions

- **Layout**: three visual groups in a single column, top to bottom — **Status** (Bankroll label, Phase label), **Action** (Wager label, bet buttons `+5`/`+10`/`+25`/`Clear`, Roll button), **Readout** (3D dice, dice-result label, round-result label). The bankroll label text stays "Bankroll".
- **View seam unchanged**: the state machine keeps calling `show_money(balance, wager)` with new values; the HUD diffs previous vs current internally to decide which chips to render. No state-machine signature changes.
- **Bankroll settle rule** (ADR-0001): `settle(true)` pays even-money profit into the balance and keeps the wager committed; `settle(false)` zeroes the wager. A winning wager persists across rounds until cleared or lost.
- **Delta mapping**: place bet → bankroll `-X` (red) + wager `+X` (green); clear → bankroll `+X` (green) + wager `-X` (red); win → bankroll `+profit` (green) only; lose → wager `-wager` (red) only. Delta shows the net result of the action, not raw balance movement.
- **Delta computation lives in a pure module**: a headless-testable helper turns `(old balance, old wager) → (new balance, new wager)` into a list of chips `(stat, sign, amount)`. The HUD calls it, then animates. No timer/tween logic inside the tested helper.
- **Timing resource**: a `timing.tres` with exported fields (`delta_count_duration`, `delta_hold_duration`, `delta_fade_duration`) totalling roughly one second; the same values apply to every event for now.
- **Phase stays a single label** that morphs between "Come Out", "Point: N" (gold), and "GAME OVER" (red), grouped under Status with the bankroll.

## Testing Decisions

- A good test asserts external behavior (final balance/wager, which chips were produced), never the internal nodes, tweens, or frame timing.
- `Bankroll` is unit-tested headlessly in `test/bankroll_smoke.gd` (updated for the new settle rule).
- The state-machine flow is tested through the view seam in `test/state_machine_smoke.gd` (updated: win expectations change to keep the wager).
- The delta helper is tested headlessly in a new test (mirrors `test/craps_rules_smoke.gd`'s style: pure, no scene, no real time).
- The `timing.tres` values are config data and are not unit-tested.
- Layout/grouping is verified by `godot --headless --quit-after 5` load and manual play, consistent with the current lack of automated HUD tests.

## Out of Scope

- Multi-column or responsive layout.
- New bet types beyond the Pass Line.
- Point-phase betting or odds bets.
- Per-event timing differences.
- Saving/loading bankroll state.
- Sound or haptic feedback.

## Further Notes

- The on-table win rule (ADR-0001) changes existing test expectations: a natural 7 on a $5 wager now ends `balance=100, wager=5` rather than `balance=105, wager=0`.
- "Delta" is the glossary term for the +/- chip; "score" is an informal synonym for Bankroll.
