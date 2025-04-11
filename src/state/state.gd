extends Node

class_name State

# Game phases
enum GamePhase {
	COME_OUT,    # Initial roll phase
	POINT,       # Point established phase
}

# Bet types
enum BetType {
	PASS_LINE,
}

# Game state variables
var game_phase
var point
var bankroll
var bet

var change_state: Callable
var previous_state: State
var hud: Node

func setup(change_state: Callable, previous_state: State, hud: Node):
	self.change_state = change_state
	self.previous_state = previous_state
	self.hud = hud
	
	# set game state values from previous_state
	if previous_state != null:
		game_phase = previous_state.game_phase
		point = previous_state.point
		bankroll = previous_state.bankroll
		bet = previous_state.bet
	else:
		# Initialize default values if no previous state
		game_phase = GamePhase.COME_OUT
		point = 0
		bankroll = 100  # Default starting bankroll
		bet = 0

func update_bet(new_bet: int):
	bet = new_bet
	hud.update_bet(bet)
