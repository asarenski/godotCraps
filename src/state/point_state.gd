extends State

class_name PointState

func setup(change_state: Callable, previous_state: State, view: Node, bankroll: Bankroll, dice_roller: DiceRoller, _params = null) -> void:
	super(change_state, previous_state, view, bankroll, dice_roller, _params)
	view.show_phase(State.GamePhase.POINT, point)
	view.roll_requested.connect(_on_roll_requested)
	# Hide betting buttons in point phase
	view.set_betting_enabled(false)

func _on_roll_requested() -> void:
	if bankroll.wager > 0:
		change_state.call(StateFactory.StateNames.ROLLING)
