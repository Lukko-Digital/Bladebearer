extends CanvasLayer
class_name UI

const MOVE_TIME = 2

@export var sword: Sword
@export var target: Target
@export var camera: MainCamera

@onready var move_timer: Timer = %MoveTimer
@onready var timer_bar: ProgressBar = %TimerBar
@onready var screen_color: ColorRect = %ScreenColor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	move_timer.wait_time = MOVE_TIME
	timer_bar.max_value = move_timer.wait_time


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	timer_bar.value = move_timer.wait_time - move_timer.time_left


func check_correct_rotation():
	if round(sword.rotation_degrees) == round(target.rotation_degrees):
		# Correct
		camera.shake(0.1, 5)
		screen_color.color = Color(Color.WHITE, 0.3)
	else:
		# Incorrect
		camera.shake(0.15, 8)
		screen_color.color = Color(Color.RED, 0.3)
	var tween = create_tween()
	tween.tween_property(screen_color, "color", Color(Color.WHITE, 0), 0.1)

	target.move()


func _on_move_timer_timeout() -> void:
	check_correct_rotation()
