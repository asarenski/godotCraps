extends Node

func _ready():
	$Start.start_game.connect(_on_start_game)

func _on_start_game():
	var persistent_state = PersistentState.new()
	persistent_state.set_hud($HUD)
	add_child(persistent_state)
	$HUD.on_start_game()
