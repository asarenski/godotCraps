extends State

class_name WinRoundState

func setup(change_state: Callable, previous_state: State, hud: Node) -> void:
	super(change_state, previous_state, hud)
	
	bankroll += bet * 2
	bet = 0
	
	hud.update_bet(bet)
	hud.update_bankroll(bankroll)
	hud.update_round_result("You Win: %d" % previous_state.bet)
	hud.showRoundResult()
	
	change_state.call(StateFactory.StateNames.COMEOUT_BETTING) 
