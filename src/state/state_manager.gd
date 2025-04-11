extends Node

class_name PersistentState

var state: State
var state_factory: StateFactory
var hud: Node

func _ready():
	state_factory = StateFactory.new()
	change_state(StateFactory.StateNames.COMEOUT_BETTING)

func set_hud(hud_node: Node):
	hud = hud_node

func change_state(new_state_name: StateFactory.StateNames):
	var previous_state = state
	if previous_state != null:
		previous_state.queue_free()
	state = state_factory.get_state(new_state_name).new()
	state.setup(Callable(self, 'change_state'), previous_state, hud)
	add_child(state)
