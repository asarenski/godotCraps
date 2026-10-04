# 04: Delta rendering + timing resource

**What to build:** The HUD renders green/red delta chips (`+$N` / `-$N`) next to the bankroll and current-bet labels, animating count-then-fade over roughly one second, with all durations pulled from a single timing resource.

**Blocked by:** 01 (reorganize HUD into three groups), 03 (delta computation helper)

**Status:** ready-for-agent

- [ ] On every `show_money`, the HUD diffs old→new via the helper (ticket 03) and renders the resulting chips next to the changed label(s).
- [ ] Chips are green for gains, red for losses, and show the net amount.
- [ ] A `timing.tres` resource holds `delta_count_duration`, `delta_hold_duration`, and `delta_fade_duration` (totalling ~1s); the HUD reads from it, not from hard-coded values.
- [ ] Animation is count-then-fade, with the same timing for every event.
- [ ] The old 0.25s `Timer` flash on the Current Bet label is removed.
