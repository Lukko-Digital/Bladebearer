extends Node3D
class_name HeartHolder

# Y position should be set to plus or minus 0.91
const Z_POSITION = -0.071
const SCALE = Vector3(0.067, 0.067, 0.067)
# Offset assumes that scale is 0.067
const HEART_OFFSET = 1.4

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

func set_hearts(num_hearts: int):
	var start_x = -HEART_OFFSET * (num_hearts - 1) / 2
	for i in range(num_hearts):
		var heart_instance: Heart = heart_scene.instantiate()
		heart_instance.position.x = start_x + i * HEART_OFFSET
		add_child(heart_instance)
		heart_array.append(heart_instance)

func break_heart_at_idx(idx: int):
	if idx < 0 or idx >= heart_array.size():
		push_error("Invalid heart index ", str(idx), " on ", self)
	heart_array[idx].break_heart()
