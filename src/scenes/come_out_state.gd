extends State

class_name ComeOutState

func _ready() -> void:
	game_phase = State.GamePhase.COME_OUT
	point = null
