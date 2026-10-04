extends State

class_name ComeOutBettingState

func setup(change_state: Callable, previous_state: State, view: Node, bankroll: Bankroll, dice_roller: DiceRoller, _params = null) -> void:
	super(change_state, previous_state, view, bankroll, dice_roller, _params)
	point = null
	view.show_money(bankroll.balance, bankroll.wager)
	view.show_phase(State.GamePhase.COME_OUT, 0)
	view.set_betting_enabled(true)
	view.bet_increased.connect(_on_bet_increased)
	view.bet_cleared.connect(_on_bet_cleared)
	view.roll_requested.connect(_on_roll_requested)
	
	if bankroll.balance == 0:
		view.show_phase(State.GamePhase.GAME_OVER, 0)
		view.set_betting_enabled(false)

func _on_bet_increased(amount: int) -> void:
	if bankroll.place_wager(amount):
		view.show_money(bankroll.balance, bankroll.wager)
		view.clear_results()

func _on_bet_cleared() -> void:
	bankroll.clear_wager()
	view.show_money(bankroll.balance, bankroll.wager)
	view.clear_results()

func _on_roll_requested() -> void:
	if bankroll.wager > 0:
		change_state.call(StateFactory.StateNames.ROLLING)
