extends Node3D
class_name HeartBorderUI

@export var camera: MainCamera

@onready var bearer_borders: Node3D = %BearerBorders
@onready var opponent_borders: Node3D = %OpponentBorders

## Coefficient to convert camera offset to border position such that the border
## stays around the hearts
const OFFSET_COEF = 120

func fade_out(bearer: bool, tween_duration: float = 1):

	var fading_parent = bearer_borders if bearer else opponent_borders
	var target_child: Sprite3D

	for child in fading_parent.get_children():
		if child.visible:
			target_child = child
		else:
			pass
	
	var original_modulate: Color = target_child.modulate

	var tween = create_tween()
	tween.tween_property(target_child, "modulate", Color(1,1,1,0), tween_duration)
	await tween.finished

	target_child.hide()
	fading_parent.hide()
	target_child.modulate = original_modulate

func set_bearer_border(bearer_rank: CombatantRank):
	set_border(bearer_rank, bearer_borders)

func set_opponent_border(opponent_rank: CombatantRank):
	set_border(opponent_rank, opponent_borders)

func set_border(rank: CombatantRank, border_parent: Node3D, fade_duration: float = 1):
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
		CombatantRank.RankName.KING:
			rank_name = "King"
	
	var target_parent = border_parent
	var target_border = target_parent.get_node(rank_name)
	var original_modulate = target_border.modulate

	target_border.modulate = Color(1,1,1,0)

	target_parent.show()
	target_border.show()

	var tween = create_tween()
	tween.tween_property(target_border, "modulate", original_modulate, fade_duration)
	await tween.finished

func hide_all(border_parent: Node3D):
	for border in border_parent.get_children():
		border.hide()
