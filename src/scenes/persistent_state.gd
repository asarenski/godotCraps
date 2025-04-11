extends Node

class_name PersistentState

var state: State
var state_factory: StateFactory

func _ready():
	state_factory = StateFactory.new()
	change_state(StateFactory.StateNames.COME_OUT)

func change_state(new_state_name: StateFactory.StateNames):
	if state != null:
		state.queue_free()
	state = state_factory.get_state(new_state_name).new()
	state.setup(Callable(self, 'change_state'), self)
	add_child(state)
