# godotCraps

A dice-control roguelite built around a modified version of craps. The player survives escalating runs of multi-roll sets by controlling dice physically and risking an increasing bankroll against progression gates.

## Language

**Bankroll**:
The player's total money, from which wagers are placed and into which winnings are paid.
_Avoid_: Wallet, purse, money

**Wager**:
The amount currently committed on the table. Placed from the bankroll; on a win the wager stays on the table and only the even-money profit is paid out, and it is returned by clearing or lost on a losing roll.
_Avoid_: Bet, stake

**Delta**:
The small colored `+$N` / `-$N` indicator shown next to a number when it changes, green for gain, red for loss. It shows the net result of an action, not the raw balance movement.
_Avoid_: Fluctuation, swing

**Come-out roll**:
The first throw of a point cycle, made before a point is established: 7 or 11 wins, 2, 3, or 12 loses, and any other total establishes the point.

**Point**:
The number established by a come-out roll (4, 5, 6, 8, 9, or 10) that must be rolled again before a 7 to win the point cycle.
_Avoid_: Target, goal
