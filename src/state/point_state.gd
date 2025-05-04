extends State

class_name PointState

func setup(change_state: Callable, previous_state: State, hud: Node, _params = null) -> void:
	super(change_state, previous_state, hud, _params)
	game_phase = State.GamePhase.POINT
	hud.update_phase("Point: %d" % point, "point")
	hud.roll_requested.connect(_on_roll_requested)
	# Hide betting buttons in point phase
	hud.get_node("BetButtons").hide()

func _on_roll_requested() -> void:
	if bet > 0:
		change_state.call(StateFactory.StateNames.ROLLING)
