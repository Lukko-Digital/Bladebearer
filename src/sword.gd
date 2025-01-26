extends Node3D
class_name Sword

const ROTATION_LERP_SPEED = 0.2

@export var swing_arm: SwingArm
@export var target: Target
@export var camera: MainCamera

@onready var sword_mesh: Node3D = $Sword

var target_rotation = Vector3()

func _ready() -> void:
	target.move.call_deferred()

func _process(_delta: float) -> void:
	handle_rotation()
	follow_swing_arm()

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
	
	# Handles Spacebar
	var yaw = 0.0
	if Input.is_action_pressed("space"):
		yaw = 90.0
	sword_mesh.rotation_degrees.y = lerp(sword_mesh.rotation_degrees.y, yaw, ROTATION_LERP_SPEED)

func follow_swing_arm():
	if swing_arm.repositioning:
		return
	get_parent().global_position = swing_arm.arm.global_position

func swing_sequence():
	await swing_arm.windup().finished
	var is_hit = check_correct_rotation()
	await swing_arm.swing(is_hit).finished
	if is_hit:
		camera.shake(0.1, 8)
	target.global_position = global_position
	target.move()

func check_correct_rotation():
	return round(rotation_degrees) == round(target.rotation_degrees)