@tool

extends Node3D
class_name SwingArm

const SWING_ARM_LENGTH = 4
## In degrees. To be animated by animation player.
## Value is an offset that is added onto `rotation_degrees.z`.
@export var swing_rotation: float

@onready var arm: Node3D = %Arm
@onready var swing_animation_player: AnimationPlayer = %SwingAnimationPlayer

## In degrees. Stores the starting z rotation before each section of the swing.
## While a swing section is animating, z rotation is set equal to `starting_z_rotation + swing_rotation`
var starting_z_rotation: float

## Either 1 or -1
var swing_direction: int = 1

func _ready() -> void:
	arm.position.y = SWING_ARM_LENGTH

	# Hide test sword during actual gameplay
	if not Engine.is_editor_hint():
		%TestingSword.hide()

func _process(_delta: float) -> void:
	# Match z rotation to `swing_rotation` export when editing scene
	if Engine.is_editor_hint():
		rotation_degrees.z = swing_rotation

	# Set z rotation to `starting_z_rotation + swing_rotation` during swing animation
	if swing_animation_player.is_playing():
		rotation_degrees.z = starting_z_rotation + (swing_rotation * swing_direction)

## Place arm behind and in line with hologram sword
func move_to_swing_position(target_rotation: Vector3):
	# order matters, rotate z, then x
	global_position = Vector3.UP.rotated(
		Vector3.BACK, deg_to_rad(target_rotation.z)
	).rotated(
		Vector3.RIGHT, deg_to_rad(target_rotation.x)
	) * -SWING_ARM_LENGTH
	rotation_degrees = target_rotation

## 50/50 to flip the swing direction
func randomize_swing_direction():
	if randi() % 2:
		swing_direction *= -1

func play_animation(animation_name: String):
	assert(swing_animation_player.has_animation(animation_name))
	
	starting_z_rotation = rotation_degrees.z
	swing_animation_player.play(animation_name)

func is_animation_playing(animation_name: String):
	return swing_animation_player.current_animation == animation_name