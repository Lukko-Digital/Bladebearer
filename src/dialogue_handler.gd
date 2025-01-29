extends Node3D
class_name DialogueHandler

@onready var sword: Sword = get_parent().find_child("Sword")
@onready var top_label: Label3D = $TopLabel
@onready var center_label: Label3D = $CenterLabel
@onready var bottom_label: Label3D = $BottomLabel

var dialogue_option_scene: PackedScene = preload("res://src/dialogue_option.tscn")
var dialogue_options: Array[DialogueOption]
var active_option = false

signal dialogue_finished
signal option_selected(option: DialogueOption)


func _process(_delta: float) -> void:
	var option = alligned_option()
	if active_option and option != null:
		if Input.is_action_just_pressed("space"):
			print(option.get_text())
			option_selected.emit(option)


func start_dialogue(options: Array[String]) -> Signal:
	await option_sequence(options)
	await text_sequence("test", 1, bottom_label)

	return dialogue_finished

func option_sequence(options: Array[String]) -> void:
	active_option = true

	var option_rotation = Vector3(0, 0, 45)
	for option in options:
		var option_instance = dialogue_option_scene.instantiate()
		add_child(option_instance)
		option_instance.set_text(option)
		option_instance.set_target_rot(option_rotation)

		option_rotation += Vector3(0, 0, -45)

	dialogue_options = []
	for node in get_children():
		if node is DialogueOption:
			dialogue_options.append(node)

	await option_selected
	end_sequence()


func text_sequence(text: String, duration: float, allignment: Label3D) -> void:
	allignment.show() # Make this a fade in
	allignment.text = text
	await get_tree().create_timer(duration).timeout
	end_sequence()


func end_sequence() -> void:
	for option in dialogue_options:
		option.queue_free()

	dialogue_options = []
	active_option = false

	top_label.hide() # Make this a fade out
	center_label.hide()
	bottom_label.hide()
	# dialogue_finished.emit()


func alligned_option() -> DialogueOption:
	for option in dialogue_options:
		if sword.is_correct_rotation(option):
			return option

	return null
