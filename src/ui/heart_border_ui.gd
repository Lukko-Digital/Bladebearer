extends CanvasLayer
class_name HeartBorderUI

@export var camera: MainCamera

@onready var shake_origin: Control = %ShakeOrigin
@onready var bearer_borders: Control = %BearerBorders
@onready var opponent_borders: Control = %OpponentBorders

# Valueguess and checkeduntiluishakematched
const SHAKE_COEF = 100

func _process(_delta: float) -> void:
	shake_origin.position = Vector2(-camera.h_offset, -camera.v_offset) * SHAKE_COEF

func set_bearer_border(bearer_rank: CombatantRank):
	set_border(bearer_rank, bearer_borders)

func set_opponent_border(opponent_rank: CombatantRank):
	set_border(opponent_rank, opponent_borders)

func set_border(rank: CombatantRank, border_parent: Control):
	hide_all(border_parent)
	border_parent.get_node(rank.name).show()

func hide_all(border_parent: Control):
	for border in border_parent.get_children():
		border.hide()
