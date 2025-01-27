extends Node3D
class_name Sword

const ROTATION_LERP_SPEED = 0.2

@export var swing_arm: SwingArm
@export var target: Target
@export var camera: MainCamera

@onready var sword_mesh: Node3D = $Sword
@onready var screen_color_animation: AnimationPlayer = %ScreenColorAnimation
@onready var sword_origin: Node3D = get_parent()
@onready var main: Node3D = get_tree().current_scene

var target_rotation = Vector3()
var previously_correct_rotation = false

func _ready() -> void:
	target.move.call_deferred()


func _process(_delta: float) -> void:
	handle_rotation()
	handle_check_rotation()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("space"):
		fast_forward_swing()


func handle_rotation():
	# Handles WASD and Shift
	target_rotation = Vector3()
	target_rotation.x = Input.get_axis("forward", "backward")
	target_rotation.z = Input.get_axis("right", "left")
	target_rotation *= 45
	if Input.is_action_pressed("shift"):
		# the max is set to 181 to the blade turns forward when w or s aren't pressed
		# surely this causes no side effects
		target_rotation.x = wrapf(180 - target_rotation.x, -180, 181)
	rotation_degrees = rotation_degrees.lerp(target_rotation, ROTATION_LERP_SPEED)


## If sword is just placed into correct rotation, flash screen
func handle_check_rotation():
	if is_correct_rotation() and not previously_correct_rotation:
		screen_color_animation.play("flash")
	previously_correct_rotation = is_correct_rotation()


func is_correct_rotation():
	return (rotation_degrees - target.target_rot).length_squared() < 1


func swing_sequence():
	attach_to_arm()
	
	swing_arm.randomize_swing_direction()

	swing_arm.windup()
	await swing_arm.swing_animation_player.animation_finished

	swing_arm.swing()
	await swing_arm.swing_animation_player.animation_finished

	if is_correct_rotation():
		camera.shake(0.1, 10)
	else:
		swing_arm.whiff()
		await swing_arm.swing_animation_player.animation_finished

	detach_from_arm()
	target.move()


func fast_forward_swing():
	if not is_correct_rotation():
		return
	if swing_arm.swing_animation_player.current_animation != "windup":
		return
	# Skip windup animation
	swing_arm.swing_animation_player.advance(INF)


func attach_to_arm():
	# Preserve global position and rotation
	var pos = sword_origin.global_position
	var rot = sword_origin.global_rotation
	sword_origin.get_parent().remove_child(sword_origin)
	swing_arm.arm.add_child(sword_origin)
	sword_origin.global_position = pos
	sword_origin.global_rotation = rot


func detach_from_arm():
	# Reset global position to zero
	swing_arm.arm.remove_child(sword_origin)
	main.add_child(sword_origin)
	sword_origin.global_position = Vector3.ZERO
	sword_origin.global_rotation = Vector3.ZERO