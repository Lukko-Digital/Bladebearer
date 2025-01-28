extends Node3D
class_name Heart

func _ready() -> void:
	%AnimationPlayer.play("Oscillate")

func break_heart():
	%HealthEmissionAnimator.play("Break")
	%AnimationPlayer.play("Break")