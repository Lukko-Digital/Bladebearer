@tool
extends Label3D
class_name LocationLabel

const ROTATION_PER_STEP = 12

# Increase to increase the alpha of all labels
const ALPHA_INTERCEPT = 0.55
# Increase to increase the alpha falloff over distance
const ALPHA_SLOPE = 0.7

var target_alpha: float

func update_wheel_visuals():
	var y = position.y
	position.z = -abs(y) / 4
	rotation_degrees.x = -5 * y * ROTATION_PER_STEP

	var alpha = 1 if round(5 * abs(y)) == 0 else ALPHA_INTERCEPT - ALPHA_SLOPE * abs(y)
	target_alpha = alpha
	modulate = Color(Color.WHITE, alpha)

func fade_in(time: float):
	transparency = 1
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(Color.WHITE, target_alpha), time)

func fade_out(time: float):
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(Color.WHITE, 0), time)