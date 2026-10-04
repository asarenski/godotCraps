extends State

class_name ComeOutBettingState

func setup(change_state: Callable, previous_state: State, hud: Node, bankroll: Bankroll, _params = null) -> void:
	super(change_state, previous_state, hud, bankroll, _params)
	point = null
	hud.update_bankroll(bankroll.balance)
	hud.update_phase("Come Out", "comeout")
	hud.get_node("BetButtons").show()
	hud.get_node("RollButton").hide()
	hud.bet_increased.connect(_on_bet_increased)
	hud.bet_cleared.connect(_on_bet_cleared)
	hud.roll_requested.connect(_on_roll_requested)
	
	if bankroll.balance == 0:
		hud.update_phase("GAME OVER", "game_over")
		hud.get_node("BetButtons").hide()

func _on_bet_increased(amount: int) -> void:
	if bankroll.place_wager(amount):
		hud.update_bankroll(bankroll.balance)
		hud.update_bet(bankroll.wager, "increase")
		hud.hide_dice_result()
		hud.hide_round_result()

func _on_bet_cleared() -> void:
	bankroll.clear_wager()
	hud.update_bankroll(bankroll.balance)
	hud.update_bet(bankroll.wager, "decrease")
	hud.hide_dice_result()
	hud.hide_round_result()

func _on_roll_requested() -> void:
	if bankroll.wager > 0:
		change_state.call(StateFactory.StateNames.ROLLING)
