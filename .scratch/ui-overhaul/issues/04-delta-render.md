# 04: Delta rendering + timing resource

**What to build:** The HUD renders green/red delta chips (`+$N` / `-$N`) next to the bankroll and wager labels, animating count-then-fade over roughly one second, with all durations pulled from a single timing resource.

**Blocked by:** 01 (reorganize HUD into three groups), 03 (delta computation helper)

**Status:** resolved

- [x] On every `show_money`, the HUD diffs old→new via the helper (ticket 03) and renders the resulting chips next to the changed label(s).
- [x] Chips are green for gains, red for losses, and show the net amount.
- [x] A `timing.tres` resource holds `delta_count_duration`, `delta_hold_duration`, and `delta_fade_duration` (totalling ~1s); the HUD reads from it, not from hard-coded values.
- [x] Animation is count-then-fade, with the same timing for every event.
- [x] The old 0.25s `Timer` flash on the Wager label is removed.

## Comments

- Added `src/config/timing.gd` (`TimingConfig` Resource) + `timing.tres` (0.3 count / 0.4 hold / 0.3 fade).
- `show_money` now diffs old→new via `Delta.diff` and renders chips on `BankrollDelta`/`WagerDelta` labels (children of the number labels, anchored to their right edge), animated count→hold→fade via a `Tween`.
- Removed the `Timer` node, its connection, and the flash helpers. All four smoke tests pass; headless load clean.
