extends RefCounted

class_name Bankroll

var balance: int
var wager: int

func _init(starting_balance: int = 100):
	balance = starting_balance
	wager = 0

func place_wager(amount: int) -> bool:
	if amount <= 0 or balance < amount:
		return false
	balance -= amount
	wager += amount
	return true

func clear_wager() -> int:
	var returned := wager
	balance += wager
	wager = 0
	return returned

func settle(won: bool) -> int:
	if won:
		balance += wager
		return wager
	wager = 0
	return 0
