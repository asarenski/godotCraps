extends Node

class_name State

# Bet types
enum BetType {
	PASS_LINE,
}

# Game state variables
var point

var change_state: Callable
var previous_state: State
var hud: Node
var bankroll: Bankroll
var dice_roller: DiceRoller

func setup(change_state: Callable, previous_state: State, hud: Node, bankroll: Bankroll, dice_roller: DiceRoller, _params = null):
	self.change_state = change_state
	self.previous_state = previous_state
	self.hud = hud
	self.bankroll = bankroll
	self.dice_roller = dice_roller
	
	# set game state values from previous_state
	if previous_state != null:
		point = previous_state.point
