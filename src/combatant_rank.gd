extends Resource
class_name CombatantRank

enum RankName {PEASANT, FOOTSOLDIER, KNIGHT, KINGSGUARD}

var num_attacks: int
var health: int
## In seconds, time that the play gets to input an attack or block.
var time_to_react: float
var name: RankName

func _init(_num_attacks: int, _health: int, _time_to_react: float, _name: RankName) -> void:
    num_attacks = _num_attacks
    health = _health
    time_to_react = _time_to_react
    name = _name