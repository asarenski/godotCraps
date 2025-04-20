extends State

class_name LoseRoundState

func setup(change_state: Callable, previous_state: State, hud: Node) -> void:
	super(change_state, previous_state, hud)
	bet = 0
	hud.update_bet(bet, "decrease")
	hud.update_round_result("You Lose!")
	hud.show_round_result()
	change_state.call(StateFactory.StateNames.COMEOUT_BETTING) 
