# 03: Delta computation helper

**What to build:** A pure module that, given old and new balance/wager, returns the list of delta chips to display — `(stat, sign, amount)` for each changed number. No rendering or animation; just the computation, so it can be tested headlessly.

**Blocked by:** 02 (on-table win resolution)

**Status:** ready-for-agent

- [ ] Given `(old balance, old wager) → (new balance, new wager)`, returns a bankroll chip for the balance diff and a current-bet chip for the wager diff, omitting any stat whose diff is zero.
- [ ] Bet +$25 produces bankroll `-25` (red) and current bet `+25` (green); clear produces the reverse.
- [ ] Win produces a bankroll `+profit` chip only; lose produces a current-bet `-wager` chip only (validated against the settled Bankroll from ticket 02).
- [ ] New headless test under `test/` asserts the full mapping and passes.
