extends CanvasLayer
class_name HeartBorderUI

@onready var bearer_borders: Control = %BearerBorders
@onready var opponent_borders: Control = %OpponentBorders

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