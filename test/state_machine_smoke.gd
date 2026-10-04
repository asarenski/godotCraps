extends SceneTree

const StateManagerScript := preload("res://src/state/state_manager.gd")
const BankrollScript := preload("res://src/state/bankroll.gd")

class TestView extends Node:
	signal bet_increased(amount: int)
	signal bet_cleared
	signal roll_requested

	var money_log: Array = []
	var phase_log: Array = []
	var betting_log: Array = []
	var result_log: Array = []
	var clear_count: int = 0

	func show_money(balance: int, wager: int):
		money_log.append([balance, wager])

	func show_phase(phase: int, point: int):
		phase_log.append([phase, point])

	func set_betting_enabled(enabled: bool):
		betting_log.append(enabled)

	func show_round_result(text: String):
		result_log.append(text)

	func clear_results():
		clear_count += 1

	func press_bet(amount: int):
		bet_increased.emit(amount)

	func press_clear():
		bet_cleared.emit()

	func press_roll():
		roll_requested.emit()


class FakeDiceRoller extends DiceRoller:
	var next_values: Array = [3, 4]

	func _ready():
		pass

	func quick_roll():
		roll_start.emit()
		var total := 0
		for v in next_values:
			total += v
		roll_complete.emit(total, next_values.duplicate())


func _init():
	_run.call_deferred()

func _run():
	var failures: Array[String] = []

	var g1 = _new_game()
	g1.view.press_bet(5)
	_expect(failures, g1.bankroll.balance == 95 and g1.bankroll.wager == 5, "bet 5 → 95/5")
	g1.view.press_clear()
	_expect(failures, g1.bankroll.balance == 100 and g1.bankroll.wager == 0, "clear → 100/0")
	g1.view.press_bet(5)
	g1.dice.next_values = [3, 4]
	g1.view.press_roll()
	_expect(failures, g1.bankroll.balance == 105 and g1.bankroll.wager == 0, "natural 7 win → 105/0")
	_expect(failures, g1.view.result_log.back() == "You Win!", "win result shown")
	_expect(failures, g1.view.phase_log.back()[0] == State.GamePhase.COME_OUT, "back in come-out")

	var g2 = _new_game()
	g2.view.press_bet(5)
	g2.dice.next_values = [1, 1]
	g2.view.press_roll()
	_expect(failures, g2.bankroll.balance == 95 and g2.bankroll.wager == 0, "craps 2 lose → 95/0")
	_expect(failures, g2.view.result_log.back() == "You Lose!", "lose result shown")

	var g3 = _new_game()
	g3.view.press_bet(5)
	g3.dice.next_values = [3, 3]
	g3.view.press_roll()
	_expect(failures, g3.view.phase_log.back()[0] == State.GamePhase.POINT, "point phase shown")
	_expect(failures, g3.view.betting_log.back() == false, "betting disabled in point phase")
	_expect(failures, g3.bankroll.balance == 95 and g3.bankroll.wager == 5, "wager held through point")
	g3.dice.next_values = [3, 3]
	g3.view.press_roll()
	_expect(failures, g3.bankroll.balance == 105 and g3.bankroll.wager == 0, "hit point win → 105/0")

	var g4 = _new_game()
	g4.view.press_bet(5)
	g4.dice.next_values = [3, 3]
	g4.view.press_roll()
	g4.dice.next_values = [3, 4]
	g4.view.press_roll()
	_expect(failures, g4.bankroll.balance == 95 and g4.bankroll.wager == 0, "seven-out lose → 95/0")
	_expect(failures, g4.view.result_log.back() == "You Lose!", "seven-out result shown")

	if failures.is_empty():
		print("PASS: state machine smoke test")
		quit(0)
	else:
		for f in failures:
			printerr("FAIL: " + f)
		quit(1)

func _new_game():
	var sm = StateManagerScript.new()
	var view = TestView.new()
	var dice = FakeDiceRoller.new()
	var bankroll = BankrollScript.new(100)
	sm.view = view
	sm.dice_roller = dice
	sm.bankroll = bankroll
	root.add_child(sm)
	return {"sm": sm, "view": view, "dice": dice, "bankroll": bankroll}

func _expect(failures: Array[String], cond: bool, name: String):
	if not cond:
		failures.append(name)
