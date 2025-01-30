@tool
extends Node3D
class_name HeartHolder

## Only used for the editor
@export var num_hearts: int = 0:
	set(value):
		num_hearts = value
		if Engine.is_editor_hint():
			set_hearts(value)

# Y position should be set to plus or minus 0.91
const Z_POSITION = 0
const SCALE = Vector3(0.067, 0.067, 0.067)
# Offset assumes that scale is 0.067
const HEART_OFFSET = 1.6

@onready var heart_scene = preload("res://src/ui/heart.tscn")

# heart_array[0] is the leftmost heart
var heart_array: Array[Heart]

func _ready():
	position.z = Z_POSITION
	scale = SCALE

func clear_hearts():
	while heart_array.size() > 0:
		var heart_instance = heart_array.pop_back()
		remove_child(heart_instance)
		heart_instance.queue_free()

func set_hearts(max_health: int, starting_health: int = -1):
	if starting_health == -1:
		starting_health = max_health

	clear_hearts()

	var start_x = -HEART_OFFSET * (max_health - 1) / 2
	for i in range(max_health):
		var heart_instance: Heart = heart_scene.instantiate()
		heart_instance.position.x = start_x + i * HEART_OFFSET
		heart_instance.set_rotation_degrees(Vector3(0, 0, randi_range(0, 30)))
		add_child(heart_instance)
		heart_array.append(heart_instance)

		if i >= starting_health:
			heart_instance.break_heart(true)

func break_heart_at_idx(idx: int):
	if idx < 0 or idx >= heart_array.size():
		push_error("Invalid heart index ", str(idx), " on ", self)
		return
	heart_array[idx].break_heart()

# ---------- FADE ----------

func fade_in(time: float):
	for heart: Heart in heart_array:
		heart.fade_in(time)

func fade_out(time: float):
	for heart: Heart in heart_array:
		heart.fade_out(time)