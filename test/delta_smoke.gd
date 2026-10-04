extends SceneTree

const DeltaScript := preload("res://src/state/delta.gd")
const BankrollScript := preload("res://src/state/bankroll.gd")

func _init():
	var failures: Array[String] = []
	var D := DeltaScript

	# Bet +$25: bankroll -25 (loss), wager +25 (gain)
	var chips: Array = D.diff(100, 0, 75, 25)
	_expect(failures, chips.size() == 2, "bet produces two chips")
	_expect(failures, _has(chips, D.Stat.BANKROLL, false, 25), "bet: bankroll -25")
	_expect(failures, _has(chips, D.Stat.WAGER, true, 25), "bet: wager +25")

	# Clear: reverse
	chips = D.diff(75, 25, 100, 0)
	_expect(failures, chips.size() == 2, "clear produces two chips")
	_expect(failures, _has(chips, D.Stat.BANKROLL, true, 25), "clear: bankroll +25")
	_expect(failures, _has(chips, D.Stat.WAGER, false, 25), "clear: wager -25")

	# Win: bankroll +profit only (validated against a settled Bankroll)
	var b := BankrollScript.new(100)
	b.place_wager(25)
	var old_balance: int = b.balance
	var old_wager: int = b.wager
	b.settle(true)
	chips = D.diff(old_balance, old_wager, b.balance, b.wager)
	_expect(failures, chips.size() == 1, "win produces one chip")
	_expect(failures, _has(chips, D.Stat.BANKROLL, true, 25), "win: bankroll +25")

	# Lose: wager -wager only
	var b2 := BankrollScript.new(100)
	b2.place_wager(25)
	old_balance = b2.balance
	old_wager = b2.wager
	b2.settle(false)
	chips = D.diff(old_balance, old_wager, b2.balance, b2.wager)
	_expect(failures, chips.size() == 1, "lose produces one chip")
	_expect(failures, _has(chips, D.Stat.WAGER, false, 25), "lose: wager -25")

	# No change: no chips
	chips = D.diff(100, 5, 100, 5)
	_expect(failures, chips.size() == 0, "no change produces no chips")

	if failures.is_empty():
		print("PASS: delta smoke test")
		quit(0)
	else:
		for f in failures:
			printerr("FAIL: " + f)
		quit(1)

func _has(chips: Array, stat: int, gain: bool, amount: int) -> bool:
	for c in chips:
		if c.stat == stat and c.gain == gain and c.amount == amount:
			return true
	return false

func _expect(failures: Array[String], cond: bool, name: String):
	if not cond:
		failures.append(name)
