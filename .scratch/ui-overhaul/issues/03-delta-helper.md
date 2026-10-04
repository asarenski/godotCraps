# 03: Delta computation helper

**What to build:** A pure module that, given old and new balance/wager, returns the list of delta chips to display — `(stat, sign, amount)` for each changed number. No rendering or animation; just the computation, so it can be tested headlessly.

**Blocked by:** 02 (on-table win resolution)

**Status:** resolved

- [x] Given `(old balance, old wager) → (new balance, new wager)`, returns a bankroll chip for the balance diff and a wager chip for the wager diff, omitting any stat whose diff is zero.
- [x] Bet +$25 produces bankroll `-25` (red) and wager `+25` (green); clear produces the reverse.
- [x] Win produces a bankroll `+profit` chip only; lose produces a wager `-wager` chip only (validated against the settled Bankroll from ticket 02).
- [x] New headless test under `test/` asserts the full mapping and passes.

## Comments

- Added `src/state/delta.gd`: a `Delta` class with `Stat { BANKROLL, WAGER }`, a `Chip` (stat/gain/amount), and a pure static `diff()`.
- Added `test/delta_smoke.gd` covering bet/clear/win/lose/no-change. All four smoke tests pass; headless load clean.
- Used the canonical `Wager` term (not "bet") per `GLOSSARY.md`.
