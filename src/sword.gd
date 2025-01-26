extends Node3D
class_name Sword

const ROTATION_LERP_SPEED = 0.2

@onready var sword_mesh: Node3D = $Sword

var target_rotation = Vector3()

func _process(_delta: float) -> void:
	handle_rotation()

func handle_rotation():
	# Handles WASD and Shift
	target_rotation = Vector3()
	target_rotation.x = Input.get_axis("forward", "backward")
	target_rotation.z = Input.get_axis("right", "left")
	target_rotation *= 45
	if Input.is_action_pressed("shift"):
		var flipped_x = 180 - target_rotation.x
		# scuffed solution to keep angle between -180 and 180 moving sword on fasted route
		if flipped_x > 180:
			flipped_x -= 360
		target_rotation.x = flipped_x
	rotation_degrees = rotation_degrees.lerp(target_rotation, ROTATION_LERP_SPEED)
	
	# Handles Spacebar
	var yaw = 0.0
	if Input.is_action_pressed("space"):
		yaw = 90.0
	sword_mesh.rotation_degrees.y = lerp(sword_mesh.rotation_degrees.y, yaw, ROTATION_LERP_SPEED)
