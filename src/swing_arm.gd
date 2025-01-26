extends Node3D
class_name SwingArm

@onready var arm: Node3D = %Arm

func move_to_swing_position(target_rotation: Vector3):
	# order matters, rotate z, then x
	global_position = Vector3.DOWN.rotated(
		Vector3.BACK, deg_to_rad(target_rotation.z)
	).rotated(
		Vector3.RIGHT, deg_to_rad(target_rotation.x)
	) * -arm.position.y

	rotation_degrees = Vector3(
		target_rotation.x - 180,
		0,
		-target_rotation.z
	)
