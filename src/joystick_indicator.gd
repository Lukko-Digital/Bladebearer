extends Node3D
class_name JoystickIndicator

## SET TO 0 IF YOU WANT TO FORWARD-BACKWARD SCALING
const SCALE_COEF = -0.7

@onready var single: AnimatedSprite3D = %Single
@onready var updown: AnimatedSprite3D = %UpDown
@onready var leftright: AnimatedSprite3D = %LeftRight
## Expect to be an immediate child of DialogueOption
@onready var option_origin: DialogueOption = get_parent()

func _process(_delta: float) -> void:
	global_rotation = Vector3.ZERO
	scale = Vector3.ONE * (1 + (global_position - option_origin.global_position).z * SCALE_COEF)

func play_animation(target_rot: Vector3):
	print(target_rot)
	if target_rot.x == 0 or target_rot.z == 0:
		single_dir(target_rot)
	else:
		two_dir(target_rot)

func single_dir(target_rot: Vector3):
	single.show()
	updown.hide()
	leftright.hide()
	match target_rot:
		Vector3(0, 0, 1) * Sword.ROTATION_ANGLE:
			single.play("left")
		Vector3(0, 0, -1) * Sword.ROTATION_ANGLE:
			single.play("left")
			single.flip_h = true
		Vector3(1, 0, 0) * Sword.ROTATION_ANGLE:
			single.play("down")
		Vector3(-1, 0, 0) * Sword.ROTATION_ANGLE:
			single.play("up")

func two_dir(target_rot: Vector3):
	single.hide()
	updown.show()
	leftright.show()
	match target_rot.x:
		float(-Sword.ROTATION_ANGLE):
			updown.play("up")
		float(Sword.ROTATION_ANGLE):
			updown.play("down")

	leftright.play("left")
	if target_rot.z < 0:
		# point right
		leftright.flip_h = true
		leftright.position.x *= -1
		updown.position.x *= -1