extends CanvasLayer

func _ready():
	hide()

func on_start_game():
	show()

func update_bankroll(bankroll):
	$Bankroll.text = "Bankroll: %d" % bankroll

func update_bet(bet):
	$Bet.text = "Current Bet: %d" % bet

func update_phase(phase_text: String):
	$Phase.text = phase_text
