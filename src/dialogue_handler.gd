extends Node3D
class_name DialogueHandler

var dialogue_option: PackedScene = preload("res://src/dialogue_option.tscn")

func start_dialogue(options: Array[String]):
	var option_rotation = Vector3(-45, 0, 45)
	for option in options:
		var option_instance = dialogue_option.instantiate()
		add_child(option_instance)
		option_instance.set_text(option)
		option_instance.set_target_rot(option_rotation)

		option_rotation += Vector3(45, 0, -45)

func end_dialogue():
	pass
