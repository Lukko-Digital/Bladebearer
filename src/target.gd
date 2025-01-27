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
		# Don't allow the same target twice, loop until new rotation is generated
		new_rot = Vector3(
			randi_range(-1, 1),
			0,
			randi_range(-1, 1)
		)
		new_rot *= 45
		if randi() % 2:
			new_rot.x = wrapf(180 - new_rot.x, -180, 180)

		if new_rot != target_rot:
			# Break when I see new rotation
			target_rot = new_rot
			break
	print(target_rot)

	swing_arm.move_to_swing_position(target_rot)

func red():
	holo_red.show()
	holo_blue.hide()

func blue():
	holo_blue.show()
	holo_red.hide()