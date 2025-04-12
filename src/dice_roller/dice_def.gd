@icon("./icon.svg")
class_name DiceDef
extends Resource

@export var name: String
@export var color: Color = Color.ANTIQUE_WHITE
@export_enum("D6:6") var sides = 6

const icons =  {
	6: preload("./d6_dice/d6_dice.svg"),
}
