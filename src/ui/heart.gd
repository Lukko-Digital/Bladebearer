@tool
extends Node3D
class_name Heart

@onready var mesh: MeshInstance3D = %Cube_cell_015

@export var material: Material

var broken: bool = false

const full_color: Color = Color(1,1,1,0.75)
const broken_color: Color = Color(1,1,1,0.2)

func _ready() -> void:

	%AnimationPlayer.play("Oscillate")

	material = material.duplicate()
	mesh.material_override = material

	# material.albedo_color = Color(1,1,1,0.5)
	# var material_tween = create_tween()
	# material_tween.tween_property(material, "albedo_color", Color(1,1,1,1), 4)

## Instant break is used when a new bearer gets the sword with not full health
func break_heart(instant = false):
	broken = true
	var speed_scale = 1000 if instant else 1
	%HealthEmissionAnimator.play("Break", -1, speed_scale)
	%AnimationPlayer.play("Break", -1, speed_scale)
	var tween = create_tween()
	tween.tween_property(material, "albedo_color", broken_color, 0.5)
	Global.sfx_player.play("Heart_Crush")

func fade_in(time: float):
	material.albedo_color = Color(1,1,1,0)
	var tween = create_tween()
	tween.tween_property(material, "albedo_color", full_color if not broken else broken_color, time)

func fade_out(time: float):
	%HealthEmissionAnimator.pause()
	var tween = create_tween()
	tween.tween_property(material, "albedo_color", Color(1,1,1,0), time)