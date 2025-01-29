extends Node3D
class_name DialogueHandler

@onready var sword: Sword = get_parent().find_child("Sword")

var dialogue_option_scene: PackedScene = preload("res://src/dialogue_option.tscn")
var dialogue_options: Array[DialogueOption]
var active = false

func _process(_delta: float) -> void:
	var option = alligned_option()
	if active and option != null:
		if Input.is_action_just_pressed("space"):
			print(option.get_text())
			end_dialogue()

func start_dialogue(options: Array[String]) -> void:
	active = true

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

func end_dialogue() -> void:
	for option in dialogue_options:
		option.queue_free()

	dialogue_options = []
	active = false

func alligned_option() -> DialogueOption:
	for option in dialogue_options:
		if sword.is_correct_rotation(option):
			return option

	return null