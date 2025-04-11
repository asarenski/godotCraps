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
var bankroll = 100
var bet = 0

var change_state: Callable
var persistent_state: PersistentState
var hud: Node

func setup(change_state: Callable, persistent_state: PersistentState, hud: Node):
	self.change_state = change_state
	self.persistent_state = persistent_state
	self.hud = hud
	self.hud.update_bankroll(bankroll)
	self.hud.update_bet(bet)

func update_bet(new_bet: int):
	bet = new_bet
	hud.update_bet(bet)
