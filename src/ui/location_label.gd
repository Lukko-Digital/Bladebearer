@tool
extends Label3D
class_name LocationLabel

const ROTATION_PER_STEP = 12

var transparency_map = {
	0: 0,
	1: 0.9,
	2: 0.95,
	3: 0.97,
	4: 0.98,
	5: 0.99,
	6: 0.99,
}

func update_wheel_visuals():
	var y = position.y
	position.z = -abs(y) / 4
	rotation_degrees.x = -5 * y * ROTATION_PER_STEP
	transparency = transparency_map[int(round(5 * abs(y)))]