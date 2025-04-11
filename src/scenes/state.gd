extends Node

class_name State

# Game phases
enum GamePhase {
	COME_OUT,    # Initial roll phase
	POINT,       # Point established phase
	RESOLUTION   # Resolving bets phase
}

# Bet types
enum BetType {
	PASS_LINE,
}

# Initial game state
var game_phase = GamePhase.COME_OUT
var point = null
var bankroll = 1000

var change_state: Callable
func setup(change_state: Callable, persistent_state: PersistentState):
	self.change_state = change_state
	self.persistent_state = persistent_state
