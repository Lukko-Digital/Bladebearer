extends Node3D
class_name Target

@export var swing_arm: SwingArm

const ROTATION_LERP_SPEED = 0.15

var target_rot: Vector3

func _process(_delta: float) -> void:
	if round(rotation_degrees) != target_rot:
		rotation_degrees = rotation_degrees.lerp(target_rot, ROTATION_LERP_SPEED)
	
func move():
	var new_rot = Vector3(
		randi_range(-1, 1),
		0,
		randi_range(-1, 1)
	)
	new_rot *= 45
	if randi() % 2:
		new_rot.x *= 3
	
	target_rot = new_rot
	print(target_rot)

	move_swing_arm()

func move_swing_arm():
	# order matters, rotate z, then x
	swing_arm.global_position = Vector3.DOWN.rotated(
		Vector3.BACK, deg_to_rad(target_rot.z)
	).rotated(
		Vector3.RIGHT, deg_to_rad(target_rot.x)
	) * 6
	print(swing_arm.global_position)
	swing_arm.rotation_degrees = Vector3(
		target_rot.x - 180,
		0,
		-target_rot.z
	)