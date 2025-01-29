extends Node3D
class_name DialogueOption

const ROTATION_LERP_SPEED = 0.07

var target_rot: Vector3

func _process(_delta: float) -> void:
	if round(rotation_degrees) != target_rot:
		rotation_degrees = rotation_degrees.lerp(target_rot, ROTATION_LERP_SPEED)