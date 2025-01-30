@tool
extends Label3D
class_name LocationLabel

func _process(_delta: float) -> void:
	update_wheel_visuals()

func update_wheel_visuals() -> void:
	var y = position.y
	position.z = -abs(y) / 4
	rotation_degrees.x = -75 * y
	transparency = 0 if y == 0 else 0.92 + 0.05 * abs(y)