extends Node
class_name StateManager

var state: State
var state_factory: StateFactory
var hud: Node
var bankroll: Bankroll
var dice_roller: DiceRoller

func _ready():
	hud = $"../HUD"
	dice_roller = $"../DiceRoller"
	state_factory = StateFactory.new()
	bankroll = Bankroll.new()
	change_state(StateFactory.StateNames.COMEOUT_BETTING)

func change_state(new_state_name: StateFactory.StateNames, params = null):
	var previous_state = state
	if previous_state != null:
		previous_state.queue_free()

	state = state_factory.get_state(new_state_name).new()
	state.setup(Callable(self, 'change_state'), previous_state, hud, bankroll, dice_roller, params)
	
	add_child(state)
