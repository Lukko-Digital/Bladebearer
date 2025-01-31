extends Resource
class_name CombatantRank

enum RankName {PEASANT, FOOTSOLDIER, KNIGHT, KINGSGUARD, KING}

var player_attacks: int
var num_attacks: int
var health: int
## In seconds, time that the play gets to input an attack or block.
var time_to_react: float
var name: RankName

func _init(
    _player_attacks: int,
    _num_attacks: int,
    _health: int,
    _time_to_react: float,
    _name: RankName
 ) -> void:
    player_attacks = _player_attacks
    num_attacks = _num_attacks
    health = _health
    time_to_react = _time_to_react
    name = _name