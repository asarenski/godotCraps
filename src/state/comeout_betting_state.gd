extends State

class_name ComeOutBettingState

func setup(change_state: Callable, previous_state: State, hud: Node, _params = null) -> void:
	super(change_state, previous_state, hud, _params)
	game_phase = State.GamePhase.COME_OUT
	point = null
	hud.update_bankroll(bankroll)
	hud.update_phase("Come Out", "comeout")
	hud.get_node("BetButtons").show()
	hud.get_node("RollButton").hide()
	hud.bet_increased.connect(_on_bet_increased)
	hud.bet_cleared.connect(_on_bet_cleared)
	hud.roll_requested.connect(_on_roll_requested)
	
	if bankroll == 0:
		hud.update_phase("GAME OVER", "game_over")
		hud.get_node("BetButtons").hide()

func _on_bet_increased(amount: int) -> void:
	if bankroll >= amount:
		update_bet(bet + amount)
		bankroll -= amount
		hud.update_bankroll(bankroll)
		hud.hide_dice_result()
		hud.hide_round_result()

func _on_bet_cleared() -> void:
	bankroll += bet
	update_bet(0)
	hud.update_bankroll(bankroll)
	hud.hide_dice_result()
	hud.hide_round_result()

func _on_roll_requested() -> void:
	if bet > 0:
		change_state.call(StateFactory.StateNames.ROLLING)
	
