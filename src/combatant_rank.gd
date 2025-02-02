extends Resource
class_name CombatantRank

enum RankName {PEASANT, FOOTSOLDIER, KNIGHT, KINGSGUARD, KING}

var player_attacks: int
var num_attacks: int
var health: int
## In seconds, time that the play gets to input an attack or block.
var time_to_react: float
## Multiplier on [Sword] rotation lerp speed
var sword_speed_multiplier: float
var name: RankName

func _init(
    _player_attacks: int,
    _num_attacks: int,
    _health: int,
    _time_to_react: float,
    _sword_speed_multiplier: float,
    _name: RankName
 ) -> void:
    player_attacks = _player_attacks
    num_attacks = _num_attacks
    health = _health
    time_to_react = _time_to_react
    sword_speed_multiplier = _sword_speed_multiplier
    name = _name