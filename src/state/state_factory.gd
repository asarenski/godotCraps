extends Node

class_name StateFactory

var states

enum StateNames {
	COMEOUT_BETTING,
	POINT,
	ROLLING,
	WIN_ROUND,
	LOSE_ROUND
}

func _init():
	states = {
		StateNames.COMEOUT_BETTING: ComeOutBettingState,
		StateNames.POINT: PointState,
		StateNames.ROLLING: RollingState,
		StateNames.WIN_ROUND: WinRoundState,
		StateNames.LOSE_ROUND: LoseRoundState
	}

func get_state(state_name):
	if states.has(state_name):
		return states.get(state_name)
	else:
		printerr("No state ", state_name, " in state factory!")
