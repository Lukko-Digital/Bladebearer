extends Node3D
class_name DialogueOption

var dialogue_handler : DialogueHandler

@onready var animation_player: AnimationPlayer = %Pointer/AnimationPlayer
@onready var label: Label3D = %Label

@onready var stick_block_effect : GPUParticles3D = %StickBlockEffect

@onready var stick : Node3D = %Stick
@onready var sword_holo : Node3D = %SwordHolo
@onready var pointer : Node3D = %Pointer


const ROTATION_LERP_SPEED = 0.07

var target_rot: Vector3
var effect: Callable

var match_effect: bool = false

var broken: bool = false

var model: String = "pointer"
var shaking: bool = false

var original_position: Vector3


func _ready():
	original_position = position

# WELCO(ME TO THE DANGER ZONE ! WELCO(ME TO THE DANGER ZONE ! WELCO(ME TO THE DANGER ZONE ! WELCO(ME TO THE DANGER ZONE ! WELCO(ME TO THE DANGER ZONE ! WELCO(ME TO THE DANGER ZONE ! 
# JOSH MAEK SURE TO ADD ANY NEW MODELS TWICE IN BOTH THES E FUCKEARS !!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!!
func set_model(_model: String):
	pointer.hide()
	stick.hide()
	sword_holo.hide()
	if _model == "pointer": pointer.show()
	if _model == "stick": stick.show()
	if _model == "sword_holo": sword_holo.show()
	if _model == "sword_holo_shake":
		sword_holo.show()
		shaking = true
# !!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!! !!!!!!!!!!!!!!!!!!!! !!!!!!!


func _process(_delta: float) -> void:
	if round(rotation_degrees) != target_rot:
		rotation_degrees = rotation_degrees.lerp(target_rot, ROTATION_LERP_SPEED)
	if shaking == true:
		position = original_position + Vector3(randf_range(-0.01, 0.01), randf_range(-0.01, 0.01), randf_range(-0.01, 0.01))

func set_text(text: String):
	label.text = text

func set_effect(_effect: Callable, match : bool = false):
	effect = _effect
	if match: match_effect = true

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
	dialogue_handler.camera.shake(0.2, 20)
	dialogue_handler.sword.transform_to_sword()
	Global.sfx_player.pick_music(false,true,false,0.2)
	

	if emit_next:
		dialogue_handler.option_selected.emit()
	else:
		dialogue_handler.breaks_left -= 1
