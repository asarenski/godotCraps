extends State

class_name EndRoundState

enum RoundResult {
	WIN,
	LOSE
}

func setup(change_state: Callable, previous_state: State, hud: Node, _params = null) -> void:
	super(change_state, previous_state, hud, _params)
	
	if _params == RoundResult.WIN:
		bankroll += bet * 2
		hud.update_round_result("You Win!")
	else:
		hud.update_round_result("You Lose!")
	
	bet = 0
	update_bet(bet)
	hud.update_bankroll(bankroll)
	hud.show_round_result()
	
	change_state.call(StateFactory.StateNames.COMEOUT_BETTING) 
