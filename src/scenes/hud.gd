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
	$RollButton.pressed.connect(_on_roll_pressed)
	
	# Sibling Connections
	dice_roller = $"../DiceRoller"
	dice_roller.roll_complete.connect(_on_roll_complete)
	
	# hide stuff
	$DiceResult.hide()
	$RoundResult.text = ""

func on_start_game():
	show()

func update_bankroll(bankroll):
	$Bankroll.text = "Bankroll: %d" % bankroll

func update_bet(bet):
	$Bet.text = "Current Bet: %d" % bet

func update_phase(phase_text: String):
	$Phase.text = phase_text

func update_dice_result(dice1: int, dice2: int):
	$DiceResult.text = "Dice: %d + %d = %d" % [dice1, dice2, dice1 + dice2]

func update_round_result(result_text: String):
	$RoundResult.text = result_text

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

func _on_roll_pressed():
	$RollButton.set_disabled(true)
	roll_requested.emit()
	dice_roller.quick_roll()

func _on_roll_complete(value: int):
	$RollButton.set_disabled(false)
	$DiceResult.show()
	var dice_values = dice_roller.result.values()
	update_dice_result(dice_values[0], dice_values[1])
