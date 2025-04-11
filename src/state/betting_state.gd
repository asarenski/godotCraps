extends State

class_name BettingState

func _ready() -> void:
	game_phase = State.GamePhase.COME_OUT  # Still in come out phase for betting purposes
	point = null
	hud.update_phase("Place Your Bets")
	
