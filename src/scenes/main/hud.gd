extends CanvasLayer

signal bet_increased(amount: int)
signal bet_cleared
signal roll_requested

var dice_roller: DiceRoller
var _last_wager: int = 0

func _ready():
	hide()
	$Action/BetButtons/Bet5.pressed.connect(_on_bet_5_pressed)
	$Action/BetButtons/Bet10.pressed.connect(_on_bet_10_pressed)
	$Action/BetButtons/Bet25.pressed.connect(_on_bet_25_pressed)
	$Action/BetButtons/ClearBet.pressed.connect(_on_clear_bet_pressed)
	
	# Sibling Connections
	dice_roller = $"../DiceRoller"
	dice_roller.roll_complete.connect(_on_roll_complete)
	dice_roller.roll_start.connect(_on_roll_start)
	$"../Start".start_game.connect(_on_start_game)
	
	# hide stuff
	clear_results()

func _on_start_game():
	show()

func _on_timer_timeout() -> void:
	$Action/Bet.remove_theme_color_override("font_color")

# --- View interface ---

func show_money(balance: int, wager: int):
	$Status/Bankroll.text = "Bankroll: %d" % balance
	$Action/Bet.text = "Current Bet: %d" % wager
	if wager > _last_wager:
		_flash_bet_increase()
	elif wager < _last_wager:
		_flash_bet_decrease()
	_last_wager = wager
	$Action/RollButton.visible = wager > 0

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
	$Action/BetButtons.visible = enabled

func show_round_result(text: String):
	$Readout/Results/RoundResult.text = text
	$Readout/Results/RoundResult.show()

func clear_results():
	$Readout/Results/DiceResult.hide()
	$Readout/Results/RoundResult.hide()

# --- Internal ---

func _flash_bet_color(color: Color):
	$Action/Timer.start()
	$Action/Bet.add_theme_color_override("font_color", color)
	
func _flash_bet_increase():
	_flash_bet_color(Color.MEDIUM_SEA_GREEN)
	
func _flash_bet_decrease():
	_flash_bet_color(Color.ORANGE_RED)

func update_dice_result(dice1: int, dice2: int):
	$Readout/Results/DiceResult.text = "Dice: %d + %d = %d" % [dice1, dice2, dice1 + dice2]

func _on_bet_5_pressed():
	bet_increased.emit(5)

func _on_bet_10_pressed():
	bet_increased.emit(10)

func _on_bet_25_pressed():
	bet_increased.emit(25)

func _on_clear_bet_pressed():
	bet_cleared.emit()

func _on_roll_start():
	$Action/RollButton.set_disabled(true)

func _on_roll_button_pressed():
	roll_requested.emit()

func _on_roll_complete(_total: int, values: Array):
	$Action/RollButton.set_disabled(false)
	update_dice_result(values[0], values[1])
	$Readout/Results/DiceResult.show()
