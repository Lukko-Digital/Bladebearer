extends Node3D
class_name SwingArm

const SWING_ARM_LENGTH = 4

@onready var arm: Node3D = %Arm

var repositioning = false

func _ready() -> void:
	arm.position.y = SWING_ARM_LENGTH

func move_to_swing_position(target_rotation: Vector3):
	repositioning = true
	# order matters, rotate z, then x
	global_position = Vector3.UP.rotated(
		Vector3.BACK, deg_to_rad(target_rotation.z)
	).rotated(
		Vector3.RIGHT, deg_to_rad(target_rotation.x)
	) * -SWING_ARM_LENGTH
	rotation_degrees = target_rotation
	repositioning = false

func windup() -> Tween:
	# windup -40 degrees
	var windup_tween = create_tween()
	windup_tween.tween_property(
		self,
		"rotation_degrees",
		rotation_degrees - Vector3(0, 0, 20),
		3
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	return windup_tween

func swing(hit: bool) -> Tween:
	var swing_tween = create_tween()

	if hit:
		swing_tween.tween_property(
			self,
			"rotation_degrees",
			rotation_degrees + Vector3(0, 0, 40),
			0.3
		).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	else:
		swing_tween.tween_property(
			self,
			"rotation_degrees",
			rotation_degrees + Vector3(0, 0, 60),
			1
		).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

	return swing_tween