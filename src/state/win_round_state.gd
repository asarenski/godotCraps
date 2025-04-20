extends State

class_name WinRoundState

func setup(change_state: Callable, previous_state: State, hud: Node) -> void:
	super(change_state, previous_state, hud)
	
	bankroll += bet * 2
	bet = 0
	
	update_bet(bet)
	hud.update_bankroll(bankroll)
	hud.update_round_result("You Win!")
	hud.show_round_result()
	
	change_state.call(StateFactory.StateNames.COMEOUT_BETTING) 
