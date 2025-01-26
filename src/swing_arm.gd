extends Node3D
class_name SwingArm

@onready var arm: Node3D = %Arm

var repositioning = false

func _ready() -> void:
	swing()

func move_to_swing_position(target_rotation: Vector3):
	repositioning = true
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
	repositioning = false

func swing():
	# windup -40 degrees
	var windup_tween = create_tween()
	windup_tween.tween_property(
		self,
		"rotation_degrees",
		rotation_degrees - Vector3(0, 0, 40),
		1
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

	await windup_tween.finished

	# swing +120 degrees
	var swing_tween = create_tween()
	swing_tween.tween_property(
		self,
		"rotation_degrees",
		rotation_degrees + Vector3(0, 0, 270),
		0.7
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
