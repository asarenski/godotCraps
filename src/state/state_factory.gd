extends Node

class_name StateFactory

var states

enum StateNames {
	COMEOUT_BETTING,
	POINT,
	ROLLING,
	END_ROUND
}

func _init():
	states = {
		StateNames.COMEOUT_BETTING: ComeOutBettingState,
		StateNames.POINT: PointState,
		StateNames.ROLLING: RollingState,
		StateNames.END_ROUND: EndRoundState
	}

func get_state(state_name):
	if states.has(state_name):
		return states.get(state_name)
	else:
		printerr("No state ", state_name, " in state factory!")
