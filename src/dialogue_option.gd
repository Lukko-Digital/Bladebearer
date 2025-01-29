extends Node3D
class_name DialogueOption

@onready var animation_player: AnimationPlayer = $Pointer2/AnimationPlayer
@onready var label: Label3D = $Label3D

const ROTATION_LERP_SPEED = 0.07

var target_rot: Vector3

func _process(_delta: float) -> void:
	if round(rotation_degrees) != target_rot:
		rotation_degrees = rotation_degrees.lerp(target_rot, ROTATION_LERP_SPEED)

func set_text(text: String):
	label.text = text

func set_target_rot(rot: Vector3):
	target_rot = rot
	label.rotation_degrees.y = rot.z * sign(rot.x)

	if rot.z > 0:
		label.rotation_degrees.z = -90
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if _anim_name == "Pointer_Idle":
		animation_player.play("Pointer_Idle")
