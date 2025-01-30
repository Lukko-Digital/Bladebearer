@tool
extends Node3D
class_name Heart

@onready var mesh: MeshInstance3D = %Cube_cell_015

var broken: bool = false

func _ready() -> void:
	%AnimationPlayer.play("Oscillate")

## Instant break is used when a new bearer gets the sword with not full health
func break_heart(instant = false):
	broken = true
	var speed_scale = 1000 if instant else 1
	%HealthEmissionAnimator.play("Break", -1, speed_scale)
	%AnimationPlayer.play("Break", -1, speed_scale)

func fade_in(time: float):
	mesh.transparency = 1
	var tween = create_tween()
	tween.tween_property(mesh, "transparency", 0.0 if not broken else 0.99, time)

func fade_out(time: float):
	%HealthEmissionAnimator.pause()
	var tween = create_tween()
	tween.tween_property(mesh, "transparency", 1, time)