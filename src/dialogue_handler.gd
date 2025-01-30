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

signal option_selected()

var breaks_left = -1

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
		{"text": "w", "match_effect": func(): alligned_option().break_stick(), "rotation": Vector3(-45, 0, 0), "alignment": Vector3(0, 1, 0)},
		],
		"stick", true)
	
	breaks_left = 2
	await option_sequence([
		{"text": "a+s", "match_effect": func(): alligned_option().break_stick(false), "rotation": Vector3(45, 0, 45)},
		{"text": "w+d", "match_effect": func(): alligned_option().break_stick(false), "rotation": Vector3(-45, 0, -45)}
		],
		"stick", true)

	breaks_left = 2
	await option_sequence([
		{"text": "a+w", "match_effect": func(): alligned_option().break_stick(false), "rotation": Vector3(-45, 0, 45)},
		{"text": "s+d", "match_effect": func(): alligned_option().break_stick(false), "rotation": Vector3(45, 0, -45)}
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

func intro() -> void:

	Global.sfx_player.pick_music(false,false,false,0)
	Global.sfx_player.play("Sword_Hit_Special")
	
	light_animation_player.play("Chest Open")
	await get_tree().create_timer(14.5).timeout ## OPENING CUTSCENE LENGTH

	await option_sequence([
		{"text": "I'm okay", "effect": func(): option_selected.emit(), "rotation": Vector3(0, 0, -45)},
		{"text": "Kill him", "effect": func(): option_selected.emit(), "rotation": Vector3(0, 0, 45)}
		])

	
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




func show_text_sequence(text: String, allignment: Label3D, dur: float = 0.5) -> void:
	allignment.transparency = 0
	allignment.text = text
	allignment.show()
	var text_tween = create_tween()
	text_tween.tween_property(allignment, "transparency", 1, dur)

func end_text_sequence(allignment: Label3D, dur: float = 0.5) -> void:
	var text_tween = create_tween()
	text_tween.tween_property(allignment, "transparency", 1, dur)





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