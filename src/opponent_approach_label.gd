extends Label3D
class_name OpponentApproachLabel

var description_map = {
	CombatantRank.RankName.PEASANT: ["a man in ragged clothes charges forward"],
	CombatantRank.RankName.FOOTSOLDIER: ["a uniformed soldier points his blade at you"],
	CombatantRank.RankName.KNIGHT: ["a figure clad in armor approaches"],
	CombatantRank.RankName.KINGSGUARD: ["a figure in regal armor blocks the way"],
}

func _ready() -> void:
	hide()
	modulate = Color(Color.WHITE, 0)

func randomize_description(rank: CombatantRank.RankName) -> String:
	return description_map[rank].pick_random()

func fade_in(time: float, description: String):
	text = description
	show()
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(Color.WHITE, 1), time)
	await tween.finished

func fade_out(time: float):
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(Color.WHITE, 0), time)
	await tween.finished
	hide()
