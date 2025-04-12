extends State

class_name RollingState

func setup(change_state: Callable, previous_state: State, hud: Node) -> void:
	super(change_state, previous_state, hud)
	hud.update_phase("Rolling...")
	
	# Connect to HUD's dice roller
	hud.dice_roller.roll_complete.connect(_on_roll_complete)

func _on_roll_complete(dice_result: int) -> void:
	# Determine next state based on roll result
	if game_phase == State.GamePhase.COME_OUT:
		match dice_result:
			7, 11:
				change_state.call(StateFactory.StateNames.WIN_ROUND)
			2, 3, 12:
				change_state.call(StateFactory.StateNames.LOSE_ROUND)
			_:
				# Point established
				point = dice_result
				change_state.call(StateFactory.StateNames.POINT)
	else:  # POINT phase
		if dice_result == point:
			change_state.call(StateFactory.StateNames.WIN_ROUND)
		elif dice_result == 7:
			change_state.call(StateFactory.StateNames.LOSE_ROUND)
		else:
			# Continue point phase
			change_state.call(StateFactory.StateNames.POINT)
