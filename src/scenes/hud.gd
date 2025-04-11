extends CanvasLayer

func _ready():
	hide()

func on_start_game():
	show()
	$Bankroll.text = "bankroll $1m"
	$Phase.text = "some phase"
