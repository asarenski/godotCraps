class_name Dice
extends RigidBody3D

@export var die_color := Color.BROWN

var sides = {}

const dice_size := 2.0
const dice_density := 10.0

var rolling := false
var roll_time := 0.0

## Emited when a roll finishes
signal roll_complete(int)

func _init():
	continuous_cd = false
	can_sleep = true
	gravity_scale = 10
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC

@onready var mesh = $DiceMesh

func _ready():
	mesh.material_override = mesh.material_override.duplicate()
	mesh.material_override.albedo_color = die_color
	mass = dice_density * dice_size**3
	stop()

func stop():
	freeze = true
	sleeping = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

func face_up_transform(value) -> Transform3D:
	"""Returns the 3D tranform to put the given value up"""
	var face_normal = (to_global(sides[value])-global_position).normalized()
	var cross = face_normal.cross(Vector3.UP).normalized()
	var angle = face_normal.angle_to(Vector3.UP)
	var rotated := Transform3D(transform)
	# Edge case: face is down
	if cross.length_squared()<0.1:
		cross = Vector3.FORWARD
	rotated.basis = rotated.basis.rotated(cross.normalized(), angle)
	return rotated

func show_face(value):
	"""Shows a given face by rotating it up"""
	assert(value in sides)
	rolling = true
	const show_face_animation_time := .3
	var rotated := face_up_transform(value)
	var tween: Tweener = create_tween().tween_property(
		self, "transform", rotated, show_face_animation_time
	)
	await tween.finished
	rolling = false
	roll_complete.emit(value)
	
