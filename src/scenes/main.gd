extends Node

func _ready():
	$Start.start_game.connect(_on_start_game)

func _on_start_game():
	PersistentState.new()
	$HUD.on_start_game()
