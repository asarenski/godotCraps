extends CanvasLayer

signal bet_increased(amount: int)
signal bet_cleared
signal roll_requested

var dice_roller: DiceRoller
var _last_wager: int = 0

func _ready():
	hide()
	$BetButtons/Bet5.pressed.connect(_on_bet_5_pressed)
	$BetButtons/Bet10.pressed.connect(_on_bet_10_pressed)
	$BetButtons/Bet25.pressed.connect(_on_bet_25_pressed)
	$BetButtons/ClearBet.pressed.connect(_on_clear_bet_pressed)
	
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
	$HUDTop/Bet.remove_theme_color_override("font_color")

# --- View interface ---

func show_money(balance: int, wager: int):
	$HUDTop/Bankroll.text = "Bankroll: %d" % balance
	$HUDTop/Bet.text = "Current Bet: %d" % wager
	if wager > _last_wager:
		_flash_bet_increase()
	elif wager < _last_wager:
		_flash_bet_decrease()
	_last_wager = wager
	$RollButton.visible = wager > 0

func show_phase(phase: int, point: int):
	match phase:
		State.GamePhase.COME_OUT:
			$HUDTop/Phase.text = "Come Out"
			$HUDTop/Phase.remove_theme_color_override("font_color")
		State.GamePhase.POINT:
			$HUDTop/Phase.text = "Point: %d" % point
			$HUDTop/Phase.add_theme_color_override("font_color", Color.GOLD)
		State.GamePhase.GAME_OVER:
			$HUDTop/Phase.text = "GAME OVER"
			$HUDTop/Phase.add_theme_color_override("font_color", Color.ORANGE_RED)

func set_betting_enabled(enabled: bool):
	$BetButtons.visible = enabled

func show_round_result(text: String):
	$Results/RoundResult.text = text
	$Results/RoundResult.show()

func clear_results():
	$Results/DiceResult.hide()
	$Results/RoundResult.hide()

# --- Internal ---

func _flash_bet_color(color: Color):
	$HUDTop/Timer.start()
	$HUDTop/Bet.add_theme_color_override("font_color", color)
	
func _flash_bet_increase():
	_flash_bet_color(Color.MEDIUM_SEA_GREEN)
	
func _flash_bet_decrease():
	_flash_bet_color(Color.ORANGE_RED)

func update_dice_result(dice1: int, dice2: int):
	$Results/DiceResult.text = "Dice: %d + %d = %d" % [dice1, dice2, dice1 + dice2]

func _on_bet_5_pressed():
	bet_increased.emit(5)

func _on_bet_10_pressed():
	bet_increased.emit(10)

func _on_bet_25_pressed():
	bet_increased.emit(25)

func _on_clear_bet_pressed():
	bet_cleared.emit()

func _on_roll_start():
	$RollButton.set_disabled(true)

func _on_roll_button_pressed():
	roll_requested.emit()

func _on_roll_complete(_total: int, values: Array):
	$RollButton.set_disabled(false)
	update_dice_result(values[0], values[1])
	$Results/DiceResult.show()
