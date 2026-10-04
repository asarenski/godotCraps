class_name Delta

enum Stat { BANKROLL, WAGER }

class Chip extends RefCounted:
	var stat: int
	var gain: bool
	var amount: int

	func _init(p_stat: int, p_gain: bool, p_amount: int):
		stat = p_stat
		gain = p_gain
		amount = p_amount

static func diff(old_balance: int, old_wager: int, new_balance: int, new_wager: int) -> Array:
	var chips: Array = []
	var balance_change: int = new_balance - old_balance
	if balance_change != 0:
		chips.append(Chip.new(Stat.BANKROLL, balance_change > 0, absi(balance_change)))
	var wager_change: int = new_wager - old_wager
	if wager_change != 0:
		chips.append(Chip.new(Stat.WAGER, wager_change > 0, absi(wager_change)))
	return chips
