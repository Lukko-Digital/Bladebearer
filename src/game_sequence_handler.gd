extends Node
class_name GameSequenceHandler

@onready var sword: Sword = get_parent()
@onready var target = sword.target

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_loop.call_deferred()

func game_loop():
	while true:
		# 50/50 block or attack
		if randi() % 2:
			target.red()
			for _i in range(randi_range(1, 1)):
				target.move()
				sword.swing_sequence()
				await sword.sequence_finished
		else:
			target.blue()
			for _i in range(randi_range(1, 2)):
				target.move()
				sword.block_sequence()
				await sword.sequence_finished
