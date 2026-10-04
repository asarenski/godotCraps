extends State

class_name RollingState

func setup(change_state: Callable, previous_state: State, hud: Node, bankroll: Bankroll, dice_roller: DiceRoller, _params = null) -> void:
	super(change_state, previous_state, hud, bankroll, dice_roller, _params)
	dice_roller.roll_complete.connect(_on_roll_complete)
	dice_roller.quick_roll()

func _on_roll_complete(total: int, _values: Array) -> void:
	match CrapsRules.resolve(total, point):
		CrapsRules.Outcome.WIN:
			change_state.call(StateFactory.StateNames.END_ROUND, EndRoundState.RoundResult.WIN)
		CrapsRules.Outcome.LOSE:
			change_state.call(StateFactory.StateNames.END_ROUND, EndRoundState.RoundResult.LOSE)
		CrapsRules.Outcome.ESTABLISH_POINT:
			point = total
			change_state.call(StateFactory.StateNames.POINT)
		CrapsRules.Outcome.CONTINUE:
			change_state.call(StateFactory.StateNames.POINT)
