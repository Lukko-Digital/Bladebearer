extends Node
class_name SfxPlayer

func _ready() -> void:
	Global.sfx_player = self

## [audio_player_name] must exactly match the name of a child
## [AudioStreamPlayer] or [AudioStreamPlayer3D] node.
func play(audio_player_name: String):
	get_node(audio_player_name).play()