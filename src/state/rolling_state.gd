extends State

class_name RollingState

func setup(change_state: Callable, previous_state: State, hud: Node, bankroll: Bankroll, _params = null) -> void:
	super(change_state, previous_state, hud, bankroll, _params)
	# Connect to HUD's dice roller
	hud.dice_roller.roll_complete.connect(_on_roll_complete)

func _on_roll_complete(dice_result: int) -> void:
	match CrapsRules.resolve(dice_result, point):
		CrapsRules.Outcome.WIN:
			change_state.call(StateFactory.StateNames.END_ROUND, EndRoundState.RoundResult.WIN)
		CrapsRules.Outcome.LOSE:
			change_state.call(StateFactory.StateNames.END_ROUND, EndRoundState.RoundResult.LOSE)
		CrapsRules.Outcome.ESTABLISH_POINT:
			point = dice_result
			change_state.call(StateFactory.StateNames.POINT)
		CrapsRules.Outcome.CONTINUE:
			change_state.call(StateFactory.StateNames.POINT)
