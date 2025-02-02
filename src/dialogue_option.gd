extends Node3D
class_name DialogueOption

var dialogue_handler: DialogueHandler

@onready var animation_player: AnimationPlayer = %Pointer/AnimationPlayer
@onready var label: Label3D = %Label

@onready var stick_block_effect: GPUParticles3D = %StickBlockEffect

@onready var stick: Node3D = %Stick
@onready var sword_holo: Node3D = %SwordHolo
@onready var sword_holo_red: Node3D = %SwordHoloRed
@onready var pointer: Node3D = %Pointer

@onready var volume_up: Node3D = %VolumeUp
@onready var volume_down: Node3D = %VolumeDown
@onready var start: Node3D = %Start

const MAX_VOLUME = 6
const MIN_VOLUME = -32
const VOLUME_INCREMENT_DB = 2

const ROTATION_LERP_SPEED = 0.07
const SELECTION_OFFSET = 0.1

var target_rot: Vector3
var target_scale: Vector3
var effect: Callable
var match_effect: Callable

var broken: bool = false

var model: String = "pointer"
var shaking: bool = false

var original_position: Vector3

var target_menu_label_transparency: Color = Color(1, 1, 1, 0)

func _ready():
	original_position = position
	target_scale = Vector3.ONE
	dialogue_handler.menu_label.transparency = 1.0

# WELCO(ME TO THE DANGER ZONE ! WELCO(ME TO THE DANGER ZONE ! WELCO(ME TO THE DANGER ZONE ! WELCO(ME TO THE DANGER ZONE ! WELCO(ME TO THE DANGER ZONE ! WELCO(ME TO THE DANGER ZONE ! 
# JOSH MAEK SURE TO ADD ANY NEW MODELS TWICE IN BOTH THES E FUCKEARS !!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!!
func set_model(_model: String):
	pointer.hide()
	stick.hide()
	sword_holo.hide()
	volume_up.hide()
	volume_down.hide()
	sword_holo_red.hide()
	start.hide()
	if _model == "pointer": pointer.show()
	if _model == "stick": stick.show()
	if _model == "sword_holo": sword_holo.show()
	if _model == "volume_up": volume_up.show()
	if _model == "volume_down": volume_down.show()
	if _model == "start": start.show()
	if _model == "sword_holo": sword_holo.show()
	if _model == "sword_holo_red": sword_holo_red.show()
	if _model == "sword_holo_shake":
		sword_holo.show()
		shaking = true
	if _model == "sword_holo_red_shake":
		sword_holo_red.show()
		shaking = true
# !!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!! !!!!!!!


func _process(_delta: float) -> void:
	if round(rotation_degrees) != target_rot:
		rotation_degrees = rotation_degrees.lerp(target_rot, ROTATION_LERP_SPEED)
	if shaking == true:
		position = original_position + Vector3(randf_range(-0.01, 0.01), randf_range(-0.01, 0.01), randf_range(-0.01, 0.01))
	
	scale = scale.lerp(target_scale, ROTATION_LERP_SPEED * 2)
	target_scale = target_scale.lerp(Vector3.ONE, ROTATION_LERP_SPEED)

	dialogue_handler.menu_label.modulate = lerp(dialogue_handler.menu_label.modulate, target_menu_label_transparency, ROTATION_LERP_SPEED)
	target_menu_label_transparency = lerp(target_menu_label_transparency, Color(1, 1, 1, 0), ROTATION_LERP_SPEED)


func select():
	target_scale = lerp(target_scale, Vector3.ONE * 1.1, ROTATION_LERP_SPEED * 3)
	target_menu_label_transparency = Color(1, 1, 1, 1)

func menu_option(opt: String):
	target_scale = Vector3.ONE * 1.6
	var main_index = AudioServer.get_bus_index("Master")
	var volume = AudioServer.get_bus_volume_db(main_index)
	if opt == "play":
		dialogue_handler.option_selected.emit()
		dialogue_handler.menu_label.hide() # TO NEVEAR BE SEEN AGAIN!!! (UNTIL MAYBE ONE DAY)
	elif opt == "volume_up":
		volume += VOLUME_INCREMENT_DB
		Global.sfx_player.play("Stick_Break")
	elif opt == "volume_down":
		volume -= VOLUME_INCREMENT_DB
		Global.sfx_player.play("Stick_Break")

	volume = clamp(volume, MIN_VOLUME, MAX_VOLUME)
	AudioServer.set_bus_volume_db(main_index, volume)


func set_text(text: String):
	label.text = text

func set_effect(_effect: Callable):
	effect = _effect

func set_match_effect(_effect: Callable):
	match_effect = _effect

func set_target_rot(rot: Vector3):
	target_rot = rot
	if label.billboard == 0:
		label.rotation_degrees.y = rot.z * sign(rot.x) # scuffed trial and error math to get the rotation to line up to be a little easier to see (i didn't want to do actual math)

		if rot.z > 0:
			label.rotation_degrees.z = -90
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

# you can't edit the animation player from imported .glb scenes, so this is a workaround to make it loop
func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if _anim_name == "Pointer_Idle":
		animation_player.play("Pointer_Idle")

func get_text() -> String:
	return label.text

func break_stick(emit_next: bool = true):
	if broken:
		return
	broken = true
	stick.hide()
	sword_holo.hide()
	pointer.hide()
	label.hide()
	stick_block_effect.restart()
	Global.sfx_player.play("Stick_Break")
	dialogue_handler.camera.shake(0.1, 10)
	await get_tree().create_timer(0.5).timeout

	if emit_next:
		dialogue_handler.option_selected.emit()
	else:
		dialogue_handler.breaks_left -= 1

func break_sword(emit_next: bool = true):
	if broken:
		return
	broken = true
	sword_holo.hide()
	label.hide()
	Global.sfx_player.play("Sword_Hit_Special")
	dialogue_handler.camera.shake(0.1, 10)
	dialogue_handler.sword.transform_to_sword()
	Global.sfx_player.pick_music(false, true, false, 0.2)
	

	if emit_next:
		dialogue_handler.option_selected.emit()
	else:
		dialogue_handler.breaks_left -= 1
