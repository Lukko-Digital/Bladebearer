extends Label3D
class_name OpponentApproachLabel

var description_map = {
	CombatantRank.RankName.PEASANT: [
		"a man in ragged clothes approaches with greedy eyes",
		"a weak soul lunges from behind",
		"you notice a gaunt face full of envy",
		"a poor soul wishes to contest the bearer"
	],
	CombatantRank.RankName.FOOTSOLDIER: [
		"a uniformed soldier points his blade",
		"a clean shaven man readies his swing",
		"a soldier approaches warily",
		"you notice a soldier eyeing you from the shadows"
	],
	CombatantRank.RankName.KNIGHT: [
		"a figure clad in armor approaches",
		"sparkling armor disrupts your vision",
		"a knight approaches, shining with metal"
	],
	CombatantRank.RankName.KINGSGUARD: [
		"a figure in regal armor blocks the way",
		"a cloaked figure approaches rapidly",
		"you can tell he's a kingsguard by his gait. fear consumes you",
		"a man as tall as a tree levels his blade at you"
	],
}

var win_messages = [
	"an easy victory",
	"another unworthy wielder",
	"the blood feels warm against your skin",
	"must move forward",
	"time to advance",
	"the battlefield beckons"
]

func _ready() -> void:
	hide()
	modulate = Color(Color.WHITE, 0)

func randomize_win_message() -> String:
	return win_messages.pick_random()

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
