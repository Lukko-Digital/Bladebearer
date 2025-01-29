extends Node3D
class_name Target

@export var sword: Sword
@export var swing_arm: SwingArm

@onready var holo_blue: Node3D = %HologramBlue
@onready var holo_red: Node3D = %HologramRed

@onready var block_effect: Node3D = %BlockEffect
@onready var hit_effect: Node3D = %HitEffect
@onready var align_effect: AnimationPlayer = %AlignEffect


const ROTATION_LERP_SPEED = 0.07

var target_rot: Vector3

func _process(_delta: float) -> void:
	if round(rotation_degrees) != target_rot:
		rotation_degrees = rotation_degrees.lerp(target_rot, ROTATION_LERP_SPEED)
	
func move():
	var new_rot: Vector3
	while true:
		# Loop until rotation satisfies `is_valid_new_rotation`.
		new_rot = Vector3(
			randi_range(-1, 1),
			0,
			randi_range(-1, 1)
		)
		new_rot *= 45
		if randi() % 2:
			new_rot.x = wrapf(180 - new_rot.x, -180, 180)

		if is_valid_new_rotation(new_rot):
			# Break when I see new rotation
			target_rot = new_rot
			break
	print(target_rot)

	swing_arm.move_to_swing_position(target_rot)


# Invalid rotations:
# 	- (0,0,0)
# 	- the same target twice in a row
# 	- 0 z rotation twice in a row
func is_valid_new_rotation(new_rot: Vector3) -> bool:
	return (
		new_rot != target_rot and
		new_rot != Vector3.ZERO and
		(target_rot.z != 0 or new_rot.z != 0)
	)

func red():
	holo_red.show()
	holo_blue.hide()

func blue():
	holo_blue.show()
	holo_red.hide()