extends Node
class_name DiceRoller

const DiceScenes = {
	6: preload("./d6_dice/d6_dice.tscn")
}

signal roll_complete(value: int)
signal roll_start()

const default_set := {
	'red': {
		'color': Color.FIREBRICK,
	},
	'yellow': {
		'color': Color.GOLDENROD,
	},
}

var dice := []
var result := {}
var rolling := false

@export var dice_set: Array[DiceDef] = []:
	set(new_value):
		if rolling:
			await roll_complete
		dice_set = new_value
		if not dice_set.is_empty():
			setup_dice()
		
var total_value:=0 :
	get:
		var total := 0
		for dice_name in result:
			total += result[dice_name]
		return total
	
func setup_dice():
	if dice_set.is_empty():
		for die_name in default_set:
			var die = DiceDef.new()
			die.name = die_name
			die.color = default_set[die_name].color
			dice_set.append(die)
			add_die_to_scene(die)

func add_die_to_scene(die: DiceDef):
	var packed_scene = DiceScenes[6]
	var scene = packed_scene.instantiate()
	scene.name = die.name
	scene.die_color = die.color
	scene.roll_complete.connect(_on_roll_complete.bind(die.name))
	add_child(scene)
	dice.append(scene)
	
func _on_roll_complete(number: int, dice_name: String):
	result[dice_name] = number
	if result.size() < dice.size():
		return
	rolling = false
	roll_complete.emit(total_value)

func quick_roll():
	"""Non-physics random values"""
	var values: Array[int] = []
	for die: Dice in dice:
		var sides := die.sides.keys()
		var chosen = sides[randi_range(0, sides.size()-1)]
		values.append(chosen)
	show_faces(values)
	roll_start.emit()

func show_faces(faces: Array[int]):
	"""Shows faces by rotating them up"""
	if rolling: return
	assert(faces.size() == dice.size())
	result={}
	rolling = true
	for i in range(faces.size()):
		dice[i].show_face(faces[i])
