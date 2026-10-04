extends SceneTree

const CrapsRulesScript := preload("res://src/state/craps_rules.gd")

func _init():
	var failures: Array[String] = []
	var R := CrapsRulesScript
	var O := R.Outcome

	_expect(failures, R.resolve(7, null) == O.WIN, "come-out 7 wins")
	_expect(failures, R.resolve(11, null) == O.WIN, "come-out 11 wins")

	_expect(failures, R.resolve(2, null) == O.LOSE, "come-out 2 loses")
	_expect(failures, R.resolve(3, null) == O.LOSE, "come-out 3 loses")
	_expect(failures, R.resolve(12, null) == O.LOSE, "come-out 12 loses")

	_expect(failures, R.resolve(4, null) == O.ESTABLISH_POINT, "come-out 4 establishes point")
	_expect(failures, R.resolve(10, null) == O.ESTABLISH_POINT, "come-out 10 establishes point")

	_expect(failures, R.resolve(6, 6) == O.WIN, "hitting point wins")
	_expect(failures, R.resolve(7, 6) == O.LOSE, "seven-out loses")
	_expect(failures, R.resolve(8, 6) == O.CONTINUE, "other roll continues")

	if failures.is_empty():
		print("PASS: craps rules smoke test")
		quit(0)
	else:
		for f in failures:
			printerr("FAIL: " + f)
		quit(1)

func _expect(failures: Array[String], cond: bool, name: String):
	if not cond:
		failures.append(name)
