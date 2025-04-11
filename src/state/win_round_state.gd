extends State

class_name WinRoundState

func setup(change_state: Callable, previous_state: State, hud: Node) -> void:
	super(change_state, previous_state, hud)
	hud.update_phase("You Win!")
	change_state.call(StateFactory.StateNames.COMEOUT_BETTING) 
