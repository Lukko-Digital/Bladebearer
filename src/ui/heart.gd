@tool
extends Node3D
class_name Heart

func _ready() -> void:
	%AnimationPlayer.play("Oscillate")

## Instant break is used when a new bearer gets the sword with not full health
func break_heart(instant = false):
	var speed_scale = 1000 if instant else 1
	%HealthEmissionAnimator.play("Break", -1, speed_scale)
	%AnimationPlayer.play("Break", -1, speed_scale)