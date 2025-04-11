extends CanvasLayer

func _ready():
	hide()

func on_start_game():
	print('HUD started')
	show()
