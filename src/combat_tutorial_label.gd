extends Node3D
class_name CombatTutorialLabel

@onready var sword: Sword = %Sword
@onready var main_label: Label3D = $MainLabel
@onready var swing: Node3D = $Swing
@onready var invert: Node3D = $Invert

@onready var x_pos = position.x
var attack_tutorial: bool = false

func _ready() -> void:
	print("asdf", x_pos)
	hide()

func _process(_delta: float) -> void:
	if attack_tutorial:
		if sword.is_correct_rotation():
			show_label(swing)
		else:
			show_label(main_label)
			main_label.text = "match to attack"

# Show the given node and hide the others
func show_label(node_to_show: Node3D) -> void:
	for node in [main_label, swing, invert]:
		node.hide()
	node_to_show.show()

func fade_in():
	show()
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(Color.WHITE, 1), 1)
	await tween.finished

func attack():
	position.x = x_pos
	attack_tutorial = true
	fade_in()

func block():
	position.x = - x_pos
	attack_tutorial = false
	show_label(main_label)
	main_label.text = "match to block"
	fade_in()

func shift_first_block():
	position.x = x_pos
	attack_tutorial = false
	show_label(main_label)
	main_label.text = "match to block"
	fade_in()

func shift():
	position.x = x_pos
	attack_tutorial = false
	show_label(invert)
	fade_in()
