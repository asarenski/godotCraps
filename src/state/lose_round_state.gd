extends State

class_name LoseRoundState

func setup(change_state: Callable, previous_state: State, hud: Node) -> void:
	super(change_state, previous_state, hud)
	hud.update_round_result("You Lose!")
	change_state.call(StateFactory.StateNames.COMEOUT_BETTING) 
