extends Node3D
class_name Sword

const ROTATION_LERP_SPEED = 10
## Threshold for determining correct sword angle. In degrees.
const CORRECT_ROTATION_THRESHOLD = 2

@onready var game_sequence_handler: GameSequenceHandler = %GameSequenceHandler
@onready var target: Target = game_sequence_handler.target
@onready var swing_arm: SwingArm = game_sequence_handler.swing_arm

@onready var screen_color_animation: AnimationPlayer = %ScreenColorAnimation

@onready var transform_effect: GPUParticles3D = %TransformEffect

@export var blood_array: Array[MeshInstance3D]

@onready var sword_model: Node3D = %Sword
@onready var stick_model: Node3D = %Stick

@onready var sword_animator: AnimationPlayer = %SwordAnimator

var target_rotation: Vector3:
	set(value):
		if input_locked:
			return
		target_rotation = value

var previously_correct_rotation = false
var blocking = false
var input_locked = false

var handling_inputs: bool = true
var lerp_speed_multiplier: float = 1.0

func _ready():
	sword_model.hide()
	stick_model.show()

func _process(delta: float) -> void:
	handle_rotation(delta)
	handle_check_rotation()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("space"):
		game_sequence_handler.lock_swing()

## ------------------------ ROTATION ------------------------

func handle_rotation(delta: float):
	if !handling_inputs:
		target_rotation = Vector3(0, 0, 0)
	else:
		# Handles WASD and Shift
		target_rotation = Vector3()
		target_rotation.x = Input.get_axis("forward", "backward")
		target_rotation.z = Input.get_axis("right", "left")
		target_rotation *= 45
		if Input.is_action_pressed("shift"):
			target_rotation.x = wrapf(180 - target_rotation.x, -180, 180)
	rotation.x = wrapf(lerp_angle(rotation.x, deg_to_rad(target_rotation.x), ROTATION_LERP_SPEED * lerp_speed_multiplier * delta), -PI, PI)
	rotation.z = wrapf(lerp_angle(rotation.z, deg_to_rad(target_rotation.z), ROTATION_LERP_SPEED * lerp_speed_multiplier * delta), -PI, PI)


## Check if sword is just placed into correct rotation
func handle_check_rotation():
	if is_correct_rotation() and not previously_correct_rotation:
		game_sequence_handler.sword_entered_correct_rotation()
	previously_correct_rotation = is_correct_rotation()


func is_correct_rotation(to: Node3D = target):
	var xdiff = angle_difference(rotation.x, deg_to_rad(to.target_rot.x))
	var zdiff = angle_difference(rotation.z, deg_to_rad(to.target_rot.z))
	return (abs(xdiff) + abs(zdiff)) < deg_to_rad(CORRECT_ROTATION_THRESHOLD)

func lock_input(set_target_rotation: Vector3 = Vector3.INF):
	if set_target_rotation != Vector3.INF:
		target_rotation = set_target_rotation
	input_locked = true

func unlock_input():
	input_locked = false

func set_lerp_speed_multiplier(speed: float):
	lerp_speed_multiplier = speed

## ------------------------ VISUALS ------------------------

## Handling adding blood to sword on impact
func add_blood():

	var keep_going: bool = true
	var blood_index: int = 0

	while keep_going:

		if !blood_array[blood_index].visible:
			blood_array[blood_index].visible = true
			keep_going = false;

		else:
			blood_index += 1
			if blood_index == blood_array.size():
				keep_going = false;

func clear_blood():

	var fade_duration: float = 1

	for blood in blood_array:
		var tween_fade = create_tween()
		tween_fade.tween_property(blood, "transparency", 1, fade_duration)

	await get_tree().create_timer(fade_duration).timeout
	
	for blood in blood_array:
		blood.visible = false
		blood.transparency = 0

func transform_to_sword():
	sword_model.show()
	stick_model.hide()
	transform_effect.restart()
	sword_animator.play("transform")
	handling_inputs = false
	await get_tree().create_timer(1.5).timeout
	handling_inputs = true