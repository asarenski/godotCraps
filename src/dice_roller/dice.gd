class_name Dice
extends RigidBody3D

@export var dice_color := Color.BROWN
@onready var original_position := position

var sides = {}
var highlight_orientation = {}

const dice_size := 2.0
const dice_density := 10.0
const ANGULAR_VELOCITY_THRESHOLD := 10.
const LINEAR_VELOCITY_THRESHOLD := 0.2 * dice_size
## If the center of the dice stops above this elevation it is considered mounted
const mounted_elevation = 0.8 * dice_size
## The minimal angle between faces (different in a d20)
const face_angle := 90.0
## how up must be a face unit vector for the face to be choosen
func max_tilt():
	return cos(deg_to_rad(face_angle/float(sides.size())))

## Whether the dice is rolling
var rolling := false
## Accomulated roll time
var roll_time := 0.0

## Emited when a roll finishes
signal roll_complete(int)

func _init():
	continuous_cd = false
	can_sleep = true
	gravity_scale = 10
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC

# Children that the sub classes should provide

@onready var collider : CollisionShape3D = $Collider
@onready var highlight_face : Node3D = $FaceHighligth
@onready var mesh = $DiceMesh

func _adjust_to_size():
	mass = dice_density * dice_size**3
	collider.shape.margin = dice_size * 0.1
	#collider.shape.size = dice_size * Vector3.ONE

func _ready():
	original_position = position
	mesh.material_override = mesh.material_override.duplicate()
	mesh.material_override.albedo_color = dice_color
	_adjust_to_size()
	stop()

func stop():
	freeze = true
	sleeping = true
	position = original_position
	position.y = 5 * dice_size
	rotation = randf_range(0, 2*PI)*Vector3(1.,1.,1.)
	#lock_rotation = true # TODO: should not be set?
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

func upper_side():
	"Returns which dice side is up, or 0 when none is clear"
	var highest_y := -INF
	var highest_side := 0
	for side in sides:
		var y = to_global(sides[side]).y
		if y < highest_y: continue
		highest_y = y
		highest_side = side
	#print("{3} Face {0} from center {1} against threshold {2}".format([
	#	highest_y, highest_y - global_position.y, max_tilt, name
	#]))
	if highest_y - global_position.y < max_tilt():
		return null
	return highest_side

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
	
