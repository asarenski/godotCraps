# 02: On-table win resolution

**What to build:** A win no longer returns the wager; the wager stays on the table and only even-money profit is paid into the bankroll. Losing still clears the wager. This makes the bankroll read as a clean score and is the foundation for the delta indicators (ADR-0001).

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] `Bankroll.settle(true)` adds the wager as profit to balance and leaves the wager unchanged.
- [ ] `Bankroll.settle(false)` zeroes the wager and leaves balance unchanged.
- [ ] `test/bankroll_smoke.gd` updated for the new settle rule and passing.
- [ ] `test/state_machine_smoke.gd` updated: natural 7 on a $5 bet ends `balance=100, wager=5`; point-hit win keeps the wager; seven-out lose ends `wager=0`. Passing.
