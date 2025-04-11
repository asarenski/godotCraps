extends Node

class_name StateFactory

var states

enum StateNames {
	COME_OUT,
	POINT
}

func _init():
	states = {
		StateNames.COME_OUT: ComeOutState,
		StateNames.POINT: PointState
}

func get_state(state_name):
	if states.has(state_name):
		return states.get(state_name)
	else:
		printerr("No state ", state_name, " in state factory!")
