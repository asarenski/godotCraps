extends CanvasLayer

signal bet_increased(amount: int)
signal bet_cleared
signal roll_requested

var dice_roller: DiceRoller

func _ready():
	hide()
	$BetButtons/Bet5.pressed.connect(_on_bet_5_pressed)
	$BetButtons/Bet10.pressed.connect(_on_bet_10_pressed)
	$BetButtons/Bet25.pressed.connect(_on_bet_25_pressed)
	$BetButtons/ClearBet.pressed.connect(_on_clear_bet_pressed)
	
	# Sibling Connections
	dice_roller = $"../DiceRoller"
	dice_roller.roll_complete.connect(_on_roll_complete)
	$"../Start".start_game.connect(_on_start_game)
	
	# hide stuff
	hide_dice_result()
	hide_round_result()

func _on_start_game():
	show()

func _on_timer_timeout() -> void:
	$HUDTop/Bet.remove_theme_color_override("font_color")

func update_bankroll(bankroll):
	$HUDTop/Bankroll.text = "Bankroll: %d" % bankroll

func _flash_bet_color(color: Color):
	$HUDTop/Timer.start()
	$HUDTop/Bet.add_theme_color_override("font_color", color)
	
func _flash_bet_increase():
	_flash_bet_color(Color.MEDIUM_SEA_GREEN)
	
func _flash_bet_decrease():
	_flash_bet_color(Color.ORANGE_RED)

func update_bet(bet: int, type: String):
	if type == "increase":
		_flash_bet_increase()
	else:
		_flash_bet_decrease()
	
	$HUDTop/Bet.text = "Current Bet: %d" % bet

func update_phase(phase_text: String, type: String):
	$HUDTop/Phase.text = phase_text
	if type == "point":
		$HUDTop/Phase.add_theme_color_override("font_color", Color.GOLD)
	elif type == "game_over":
		$HUDTop/Phase.add_theme_color_override("font_color", Color.ORANGE_RED)
	else:
		$HUDTop/Phase.remove_theme_color_override("font_color")

func update_dice_result(dice1: int, dice2: int):
	$Results/DiceResult.text = "Dice: %d + %d = %d" % [dice1, dice2, dice1 + dice2]

func update_round_result(result_text: String):
	$Results/RoundResult.text = result_text
	
func show_dice_result():
	$Results/DiceResult.show()

func hide_dice_result():
	$Results/DiceResult.hide()
	
func show_round_result():
	$Results/RoundResult.show()
	
func hide_round_result():
	$Results/RoundResult.hide()

func _on_bet_5_pressed():
	$RollButton.show()
	bet_increased.emit(5)

func _on_bet_10_pressed():
	$RollButton.show()
	bet_increased.emit(10)

func _on_bet_25_pressed():
	$RollButton.show()
	bet_increased.emit(25)

func _on_clear_bet_pressed():
	$RollButton.hide()
	bet_cleared.emit()

func _on_roll_button_pressed():
	$RollButton.set_disabled(true)
	roll_requested.emit()
	dice_roller.quick_roll()

func _on_roll_complete(value: int):
	$RollButton.set_disabled(false)
	var dice_values = dice_roller.result.values()
	update_dice_result(dice_values[0], dice_values[1])
	show_dice_result()
