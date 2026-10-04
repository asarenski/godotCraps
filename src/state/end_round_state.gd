extends State

class_name EndRoundState

enum RoundResult {
	WIN,
	LOSE
}

func setup(change_state: Callable, previous_state: State, view: Node, bankroll: Bankroll, dice_roller: DiceRoller, _params = null) -> void:
	super(change_state, previous_state, view, bankroll, dice_roller, _params)
	
	if _params == RoundResult.WIN:
		bankroll.settle(true)
		view.show_round_result("You Win!")
	else:
		bankroll.settle(false)
		view.show_round_result("You Lose!")
	
	view.show_money(bankroll.balance, bankroll.wager)
	
	change_state.call(StateFactory.StateNames.COMEOUT_BETTING)
