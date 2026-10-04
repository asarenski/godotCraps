extends SceneTree

const BankrollScript := preload("res://src/state/bankroll.gd")

func _init():
	var failures: Array[String] = []

	var b = BankrollScript.new(100)
	_expect(failures, b.balance == 100, "starting balance")
	_expect(failures, b.wager == 0, "starting wager")

	_expect(failures, b.place_wager(25) == true, "place wager succeeds")
	_expect(failures, b.balance == 75, "balance debited")
	_expect(failures, b.wager == 25, "wager credited")

	_expect(failures, b.place_wager(100) == false, "over-wager rejected")
	_expect(failures, b.balance == 75 and b.wager == 25, "state unchanged after reject")

	_expect(failures, b.clear_wager() == 25, "clear returns amount")
	_expect(failures, b.balance == 100 and b.wager == 0, "clear restores balance")

	b.place_wager(50)
	_expect(failures, b.settle(true) == 100, "win pays 2x")
	_expect(failures, b.balance == 150 and b.wager == 0, "win updates balance")

	b.place_wager(50)
	_expect(failures, b.settle(false) == 0, "loss pays 0")
	_expect(failures, b.balance == 100 and b.wager == 0, "loss keeps balance debited")

	if failures.is_empty():
		print("PASS: bankroll smoke test")
		quit(0)
	else:
		for f in failures:
			printerr("FAIL: " + f)
		quit(1)

func _expect(failures: Array[String], cond: bool, name: String):
	if not cond:
		failures.append(name)
