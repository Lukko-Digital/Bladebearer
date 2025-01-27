extends Node3D
class_name Sword

const ROTATION_LERP_SPEED = 0.2

@export var swing_arm: SwingArm
@export var target: Target
@export var camera: MainCamera

@onready var sword_mesh: Node3D = $Sword
@onready var screen_color_animation: AnimationPlayer = %ScreenColorAnimation
@onready var game_sequence_handler: GameSequenceHandler = %GameSequenceHandler
@onready var sword_origin: Node3D = get_parent()
@onready var main: Node3D = get_tree().current_scene

signal sequence_finished

var target_rotation = Vector3()
var previously_correct_rotation = false
var blocking = false
var correct_swing = false

# func _ready() -> void:
# 	target.move.call_deferred()


func _process(_delta: float) -> void:
	handle_rotation()
	handle_check_rotation()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("space"):
		lock_swing()


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
		if blocking:
			swing_arm.swing_animation_player.advance(INF)
			target.block_effect.restart()
		else:
			target.align_effect.play("Sword_Aligned")
	previously_correct_rotation = is_correct_rotation()


func is_correct_rotation():
	return (rotation_degrees - target.target_rot).length_squared() < 1


func swing_sequence():
	blocking = false # IAN THIS MIGHT BE THE WRONG PLACE TO PUT THIS
	attach_to_arm()
	
	swing_arm.randomize_swing_direction()

	swing_arm.windup()
	await swing_arm.swing_animation_player.animation_finished
	
	if correct_swing:
		swing_arm.swing()
		await swing_arm.swing_animation_player.animation_finished
		camera.shake(0.2, 15)
		target.hit_effect.restart()
	else:
		swing_arm.falter()
		await swing_arm.swing_animation_player.animation_finished

	correct_swing = false
	detach_from_arm()
	sequence_finished.emit()


func block_sequence():
	attach_to_arm()
	swing_arm.randomize_swing_direction()
	blocking = true

	swing_arm.block()
	await swing_arm.swing_animation_player.animation_finished

	if is_correct_rotation():
		camera.shake(0.2, 15)
	else:
		camera.shake(0.1, 6)
		screen_color_animation.play("red_flash")
	
	detach_from_arm()
	sequence_finished.emit()


func lock_swing():
	if swing_arm.swing_animation_player.current_animation != "windup":
		return
	# Skip windup animation
	correct_swing = is_correct_rotation()
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
