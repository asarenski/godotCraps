extends State

class_name RollingState

var dice_result: int = 0

func setup(change_state: Callable, previous_state: State, hud: Node) -> void:
	super(change_state, previous_state, hud)
	hud.update_phase("Rolling...")
	roll_dice()

func roll_dice() -> void:
	var die1 = randi_range(1, 6)
	var die2 = randi_range(1, 6)
	dice_result = die1 + die2
	
	# Determine next state based on roll result
	if game_phase == State.GamePhase.COME_OUT:
		match dice_result:
			7, 11:
				handle_win()
			2, 3, 12:
				handle_lose()
			_:
				# Point established
				point = dice_result
				change_state.call(StateFactory.StateNames.POINT)
	else:  # POINT phase
		if dice_result == point:
			handle_win()
		elif dice_result == 7:
			handle_lose()
		else:
			# Continue point phase
			change_state.call(StateFactory.StateNames.POINT)

func handle_win() -> void:
	bankroll += bet * 2
	hud.update_bankroll(bankroll)
	change_state.call(StateFactory.StateNames.WIN_ROUND)

func handle_lose() -> void:
	bet = 0
	hud.update_bet(bet)
	change_state.call(StateFactory.StateNames.LOSE_ROUND) 
