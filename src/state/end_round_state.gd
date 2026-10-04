extends State

class_name EndRoundState

enum RoundResult {
	WIN,
	LOSE
}

func setup(change_state: Callable, previous_state: State, hud: Node, bankroll: Bankroll, _params = null) -> void:
	super(change_state, previous_state, hud, bankroll, _params)
	
	if _params == RoundResult.WIN:
		bankroll.settle(true)
		hud.update_round_result("You Win!")
	else:
		bankroll.settle(false)
		hud.update_round_result("You Lose!")
	
	hud.update_bet(bankroll.wager, "decrease")
	hud.update_bankroll(bankroll.balance)
	hud.show_round_result()
	
	change_state.call(StateFactory.StateNames.COMEOUT_BETTING)
