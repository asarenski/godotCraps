# 03: State-machine signal lifecycle navigation note

**What to build:** A navigation note in AGENTS.md's state-machine section documenting the signal-connection lifecycle, so future agents don't rediscover the stale-signal bug that cost significant debugging.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] Add to the AGENTS.md "Architecture" → state-machine section: states connect to shared `view`/`dice_roller` signals in `setup()` and only disconnect on `queue_free` (deferred free), so connections can outlive the state during a single frame.
- [ ] Note the rule: one-shot events (`roll_requested`, `roll_complete`) must connect with `CONNECT_ONE_SHOT`, so a prior state's still-connected handler can't double-fire.

## Notes

- Reference: `src/state/rolling_state.gd`, `src/state/point_state.gd`, and `src/state/comeout_betting_state.gd` already use `CONNECT_ONE_SHOT`.
- This is a navigation pointer (helps an agent find/understand the gotcha), not a mechanical check; it belongs in AGENTS.md, not a linter.
