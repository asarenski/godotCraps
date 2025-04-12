extends Node

#^"A"     # Points to the direct child A.
#^"A/B"   # Points to A's child B.
#^"."     # Points to the current node.
#^".."    # Points to the parent node.
#^"../C"  # Points to the sibling node C.
#^"../.." # Points to the grandparent node.

func _ready():
	$Start.start_game.connect(_on_start_game)

func _on_start_game():
	$DiceRoller.setup_dice()
	$HUD.on_start_game()
