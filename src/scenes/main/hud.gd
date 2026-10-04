extends CanvasLayer

signal wager_increased(amount: int)
signal wager_cleared
signal roll_requested

const TIMING := preload("res://src/config/timing.tres")

var dice_roller: DiceRoller
var _last_balance: int = -1
var _last_wager: int = -1
var _delta_tweens: Dictionary = {}

func _ready():
	hide()
	$Action/WagerButtons/Wager5.pressed.connect(_on_wager_5_pressed)
	$Action/WagerButtons/Wager10.pressed.connect(_on_wager_10_pressed)
	$Action/WagerButtons/Wager25.pressed.connect(_on_wager_25_pressed)
	$Action/WagerButtons/ClearWager.pressed.connect(_on_clear_wager_pressed)
	
	# Sibling Connections
	dice_roller = $"../DiceRoller"
	dice_roller.roll_complete.connect(_on_roll_complete)
	dice_roller.roll_start.connect(_on_roll_start)
	$"../Start".start_game.connect(_on_start_game)
	
	# hide stuff
	clear_results()

func _on_start_game():
	show()

# --- View interface ---

func show_money(balance: int, wager: int):
	$Status/Bankroll.text = "Bankroll: %d" % balance
	$Action/Wager.text = "Wager: %d" % wager
	if _last_balance >= 0:
		for chip in Delta.diff(_last_balance, _last_wager, balance, wager):
			_render_chip(chip)
	_last_balance = balance
	_last_wager = wager
	_set_reserved_visible($Action/RollButton, wager > 0)

func show_phase(phase: int, point: int):
	match phase:
		State.GamePhase.COME_OUT:
			$Status/Phase.text = "Come Out"
			$Status/Phase.remove_theme_color_override("font_color")
		State.GamePhase.POINT:
			$Status/Phase.text = "Point: %d" % point
			$Status/Phase.add_theme_color_override("font_color", Color.GOLD)
		State.GamePhase.GAME_OVER:
			$Status/Phase.text = "GAME OVER"
			$Status/Phase.add_theme_color_override("font_color", Color.ORANGE_RED)

func set_betting_enabled(enabled: bool):
	_set_reserved_visible($Action/WagerButtons, enabled)

func show_round_result(text: String):
	$Readout/Results/RoundResult.text = text
	$Readout/Results/RoundResult.show()

func clear_results():
	$Readout/Results/DiceResult.hide()
	$Readout/Results/RoundResult.hide()

# --- Internal ---

func _set_reserved_visible(control: Control, shown: bool) -> void:
	control.modulate.a = 1.0 if shown else 0.0
	if control is BaseButton:
		control.mouse_filter = Control.MOUSE_FILTER_STOP if shown else Control.MOUSE_FILTER_IGNORE
	else:
		for child in control.get_children():
			if child is BaseButton:
				child.mouse_filter = Control.MOUSE_FILTER_STOP if shown else Control.MOUSE_FILTER_IGNORE

func _render_chip(chip: Delta.Chip) -> void:
	var label: Label
	match chip.stat:
		Delta.Stat.BANKROLL:
			label = $Status/Bankroll/BankrollDelta
		Delta.Stat.WAGER:
			label = $Action/Wager/WagerDelta
		_:
			return
	_animate_chip(label, chip)

func _animate_chip(label: Label, chip: Delta.Chip) -> void:
	if _delta_tweens.has(label) and _delta_tweens[label] != null:
		_delta_tweens[label].kill()
	var sign := "+" if chip.gain else "-"
	var color := Color.MEDIUM_SEA_GREEN if chip.gain else Color.ORANGE_RED
	label.add_theme_color_override("font_color", color)
	label.modulate.a = 1.0
	var tween := create_tween()
	_delta_tweens[label] = tween
	var amount := float(chip.amount)
	tween.tween_method(
		func(v: float): label.text = "%s$%d" % [sign, int(v)],
		0.0, amount, TIMING.delta_count_duration
	)
	tween.tween_interval(TIMING.delta_hold_duration)
	tween.tween_property(label, "modulate:a", 0.0, TIMING.delta_fade_duration)

func update_dice_result(dice1: int, dice2: int):
	$Readout/Results/DiceResult.text = "Dice: %d + %d = %d" % [dice1, dice2, dice1 + dice2]

func _on_wager_5_pressed():
	wager_increased.emit(5)

func _on_wager_10_pressed():
	wager_increased.emit(10)

func _on_wager_25_pressed():
	wager_increased.emit(25)

func _on_clear_wager_pressed():
	wager_cleared.emit()

func _on_roll_start():
	$Action/RollButton.set_disabled(true)

func _on_roll_button_pressed():
	roll_requested.emit()

func _on_roll_complete(_total: int, values: Array):
	$Action/RollButton.set_disabled(false)
	update_dice_result(values[0], values[1])
	$Readout/Results/DiceResult.show()
