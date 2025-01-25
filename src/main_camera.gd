extends Camera3D
class_name MainCamera

@onready var shake_timer: Timer = $ShakeTimer
var default_h_offset = h_offset
var default_v_offset = v_offset

var shake_amount: float

func _process(_delta: float) -> void:
	h_offset = default_h_offset
	v_offset = default_v_offset
	handle_shake()

func handle_shake():
	if shake_timer.is_stopped():
		return
	h_offset = randf_range(-1, 1) * shake_amount
	v_offset = randf_range(-1, 1) * shake_amount

func shake(duration: float, amount: float):
	shake_timer.start(duration)
	shake_amount = amount