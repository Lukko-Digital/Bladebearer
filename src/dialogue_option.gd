extends Node3D
class_name DialogueOption

@onready var animation_player: AnimationPlayer = $Pointer2/AnimationPlayer
@onready var label: Label3D = $Pointer2/Label3D

const ROTATION_LERP_SPEED = 0.07

var target_rot: Vector3
var effect: Callable

func _process(_delta: float) -> void:
	if round(rotation_degrees) != target_rot:
		rotation_degrees = rotation_degrees.lerp(target_rot, ROTATION_LERP_SPEED)

func set_text(text: String):
	label.text = text

func set_effect(_effect: Callable):
	effect = _effect

func set_target_rot(rot: Vector3):
	target_rot = rot
	if label.billboard == 0:
		label.rotation_degrees.y = rot.z * sign(rot.x) # scuffed trial and error math to get the rotation to line up to be a little easier to see (i didn't want to do actual math)

		if rot.z > 0:
			label.rotation_degrees.z = -90
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

# you can't edit the animation player from imported .glb scenes, so this is a workaround to make it loop
func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if _anim_name == "Pointer_Idle":
		animation_player.play("Pointer_Idle")

func get_text() -> String:
	return label.text