extends Label3D
class_name CombatTutorialLabel

@onready var sword = %Sword

var attack_tutorial: bool = false

func _ready() -> void:
	hide()

func _process(_delta: float) -> void:
	if attack_tutorial:
		if sword.is_correct_rotation():
			text = "space to swing"
		else:
			text = "match to attack"

func fade_in():
	show()
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(Color.WHITE, 1), 1)
	await tween.finished

func attack():
	attack_tutorial = true
	text = "attack"
	fade_in()

func block():
	position.x *= -1
	attack_tutorial = false
	text = "match to block"
	fade_in()