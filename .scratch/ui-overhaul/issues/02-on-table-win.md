# 02: On-table win resolution

**What to build:** A win no longer returns the wager; the wager stays on the table and only even-money profit is paid into the bankroll. Losing still clears the wager. This makes the bankroll read as a clean score and is the foundation for the delta indicators (ADR-0001).

**Blocked by:** None (can start immediately)

**Status:** resolved

- [x] `Bankroll.settle(true)` adds the wager as profit to balance and leaves the wager unchanged.
- [x] `Bankroll.settle(false)` zeroes the wager and leaves balance unchanged.
- [x] `test/bankroll_smoke.gd` updated for the new settle rule and passing.
- [x] `test/state_machine_smoke.gd` updated: natural 7 on a $5 bet ends `balance=100, wager=5`; point-hit win keeps the wager; seven-out lose ends `wager=0`. Passing.

## Comments

- Changed `settle()` to pay even-money profit and keep the wager on a win (ADR-0001).
- The on-table rule exposed a latent stale-signal cascade in the synchronous smoke test (deferred `queue_free` leaves old `roll_requested`/`roll_complete` handlers connected). Fixed with `CONNECT_ONE_SHOT` on those once-per-state connections in `comeout_betting_state`, `point_state`, and `rolling_state`.
- All three smoke tests pass; headless load clean.
