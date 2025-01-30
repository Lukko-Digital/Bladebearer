extends Node3D
class_name HeartBorderUI

@export var camera: MainCamera

@onready var bearer_borders: Node3D = %BearerBorders
@onready var opponent_borders: Node3D = %OpponentBorders

## Coefficient to convert camera offset to border position such that the border
## stays around the hearts
const OFFSET_COEF = 120

func set_bearer_border(bearer_rank: CombatantRank):
	set_border(bearer_rank, bearer_borders)

func set_opponent_border(opponent_rank: CombatantRank):
	set_border(opponent_rank, opponent_borders)

func set_border(rank: CombatantRank, border_parent: Node3D):
	hide_all(border_parent)
	# String must correspond to the name of a border node in the scene.
	var rank_name: String
	match rank.name:
		CombatantRank.RankName.PEASANT:
			rank_name = "Peasant"
		CombatantRank.RankName.FOOTSOLDIER:
			rank_name = "Footsoldier"
		CombatantRank.RankName.KNIGHT:
			rank_name = "Knight"
		CombatantRank.RankName.KINGSGUARD:
			rank_name = "Kingsguard"
	border_parent.get_node(rank_name).show()

func hide_all(border_parent: Node3D):
	for border in border_parent.get_children():
		border.hide()
