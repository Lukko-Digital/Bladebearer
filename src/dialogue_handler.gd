extends Node3D
class_name DialogueHandler

@export var light_animation_player: AnimationPlayer

@onready var sword: Sword = %Sword
@onready var top_label: Label3D = $TopLabel
@onready var center_label: Label3D = $CenterLabel
@onready var bottom_label: Label3D = $BottomLabel
@onready var menu_label: Label3D = $MenuLabel

@onready var camera: Camera3D = %MainCamera

var dialogue_option_scene: PackedScene = preload("res://src/dialogue_option.tscn")
var dialogue_options: Array[DialogueOption]
var active_option = false

var is_menu: bool = false
var kill: bool # used to chec k if player chose to kill friend in the start of the game

signal option_selected()

var breaks_left = -1

func _ready():
	top_label.modulate = Color(1,1,1,0)
	bottom_label.modulate = Color(1,1,1,0)
	center_label.modulate = Color(1,1,1,0)
	menu_label.modulate = Color(1,1,1,0)

func _process(_delta: float) -> void:
	if active_option:
		var option = alligned_option()
		if option != null:
			if option.match_effect: option.match_effect.call()
			if Input.is_action_just_pressed("space"):
				if option.effect: option.effect.call()
	
	if breaks_left == 0:
		option_selected.emit()
		breaks_left = -1

			



func tutorial() -> void:
	
	await option_sequence([
		{"text": "a", "match_effect": func(): alligned_option().break_stick(), "rotation": Vector3(0, 0, 45), "alignment": Vector3(0, 0.1, 0)},
		], 
		"stick", true)
	
	await option_sequence([
		{"text": "d", "match_effect": func(): alligned_option().break_stick(), "rotation": Vector3(0, 0, -45)}
		],
		"stick", true)
	
	await option_sequence([
		{"text": "s", "match_effect": func(): alligned_option().break_stick(), "rotation": Vector3(45, 0, 0)},
		],
		"stick", true)

	await option_sequence([
		{"text": "w", "match_effect": func(): alligned_option().break_stick(), "rotation": Vector3(-45, 0, 0), "alignment": Vector3(0, 1.5, 0)},
		],
		"stick", true)
	
	breaks_left = 2
	await option_sequence([
		{"text": "a s", "match_effect": func(): alligned_option().break_stick(false), "rotation": Vector3(45, 0, 45)},
		{"text": "w d", "match_effect": func(): alligned_option().break_stick(false), "rotation": Vector3(-45, 0, -45)}
		],
		"stick", true)

	breaks_left = 2
	await option_sequence([
		{"text": "a w", "match_effect": func(): alligned_option().break_stick(false), "rotation": Vector3(-45, 0, 45)},
		{"text": "s d", "match_effect": func(): alligned_option().break_stick(false), "rotation": Vector3(45, 0, -45)}
		],
		"stick", true)
	
	await option_sequence([
		{"text": "", "match_effect": func(): alligned_option().break_sword(), "rotation": Vector3(0, 0, -45)},
		],
		"sword_holo_shake", false)

func menu() -> void:
	is_menu = true
	await option_sequence([
		{"text": "", "match_effect": func(): alligned_option().select(), "effect": func(): alligned_option().menu_option("play"), "rotation": Vector3(45, 0, 0), "model": "start"},
		{"text": "", "match_effect": func(): alligned_option().select(), "effect": func(): alligned_option().menu_option("volume_down"), "rotation": Vector3(0, 0, 45), "model": "volume_down"},
		{"text": "", "match_effect": func(): alligned_option().select(), "effect": func(): alligned_option().menu_option("volume_up"), "rotation": Vector3(0, 0, -45), "model": "volume_up"}
		])
	is_menu = false



###### INTRO CUTSCENE ########
func intro() -> void:

	Global.sfx_player.pick_music(false,false,false,0)
	Global.sfx_player.play("Sword_Hit_Special")
	
	light_animation_player.play("Chest Open")
	await get_tree().create_timer(14.5).timeout ## OPENING CUTSCENE LENGTH

	await option_sequence([
		{"text": "\"i'm okay\"", "effect": func(): intro_choice(false), "rotation": Vector3(0, 0, -45)},
		{"text": "kill him", "effect": func(): intro_choice(true), "rotation": Vector3(0, 0, 45)}
		])
	
	if kill:
		light_animation_player.play("kill_him")
		await get_tree().create_timer(4.5).timeout
	else:
		light_animation_player.play("spare_him")
		await get_tree().create_timer(6).timeout

func intro_choice(_kill: bool):
	kill = _kill
	option_selected.emit()

var kill_king: bool

func king_scene():
	pass
	## STUMBLE IN ON KING, BEGS FOR HIS LIFE

	light_animation_player.play("king_begging")
	await get_tree().create_timer(7.5).timeout

	## DECIDE WHETHER YOU WANT TO KILL HIM OR YOURSELF
	await option_sequence([
		{"text": "end it", "effect": func(): king_choice(false), "rotation": Vector3(0, 0, 45), "model": "sword_holo_shake"},
		{"text": "end him", "effect": func(): king_choice(true), "rotation": Vector3(0, 0, -45), "model": "sword_holo_red_shake"}
		])
	
	if kill_king:
		light_animation_player.play("king_execution")
		await get_tree().create_timer(5).timeout
	else:
		light_animation_player.play("king_spared")
		await get_tree().create_timer(7.2).timeout

func king_choice(_kill_king: bool):
	kill_king = _kill_king
	option_selected.emit()

#### ABSOLUTELY HELLISH FUNCTION INCOMING #######
func option_sequence(options: Array[Dictionary], model : String = "pointer", _tutorial: bool = false) -> void:
	active_option = true

	for option in options:
		var option_instance = dialogue_option_scene.instantiate()
		option_instance.dialogue_handler = self
		add_child(option_instance)
		option_instance.set_model(model)

		if _tutorial:
			if option.has("alignment"): option_instance.label.position += option.alignment
			option_instance.label.position += Vector3(-0.04, 0, 0)
			option_instance.label.billboard = 1
			option_instance.label.font_size = 35
			if option["text"] == "w":
				option_instance.label.font_size = 55
				option_instance.label.scale = Vector3.ONE * 1.3

		option_instance.set_text(option["text"])
		if option.has("effect"):
			option_instance.set_effect(option["effect"])
		if option.has("match_effect"):
				option_instance.set_match_effect(option["match_effect"])
		option_instance.set_target_rot(option["rotation"])
		if option.has("model"):
				option_instance.set_model(option["model"])

	dialogue_options = []
	for node in get_children():
		if node is DialogueOption:
			dialogue_options.append(node)

	await option_selected
	end_option_sequence()
	if !is_menu:
		await get_tree().create_timer(0.1).timeout

# func text_sequence(text: String, duration: float, allignment: Label3D) -> void:
# 	allignment.show() # Make this a fade in
# 	allignment.text = text
# 	await get_tree().create_timer(duration).timeout
# 	end_text_sequence()




func show_text_sequence(text: String, allignment: int, dur: float = 0.2) -> void:
	var _label: Label3D
	if allignment == 1: _label = top_label
	elif allignment == 2: _label = center_label
	elif allignment == 3: _label = bottom_label
	_label.modulate = Color(0,0,0,0)
	_label.text = text
	_label.show()
	var text_tween = create_tween()
	text_tween.tween_property(_label, "modulate", Color(1,1,1,1), dur)
	print("labelling")

func end_text_sequence(allignment: int, dur: float = 0.6) -> void:
	var _label: Label3D
	if allignment == 1: _label = top_label
	elif allignment == 2: _label = center_label
	elif allignment == 3: _label = bottom_label
	var text_tween = create_tween()
	text_tween.tween_property(_label, "modulate", Color(0,0,0,0), dur)





func end_option_sequence() -> void:
	active_option = false

	for option in dialogue_options:
		option.queue_free()

	dialogue_options = []




func alligned_option() -> DialogueOption:
	for option in dialogue_options:
		if option != null and sword.is_correct_rotation(option):
			return option

	return null
