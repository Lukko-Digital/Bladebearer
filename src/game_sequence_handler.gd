## Acts as the sword origin, childs and dechilds from the swing arm.
## Parent of sword, target, camera.
## Handles main game loop and is the main way that the swing arm, target, camera,
## and sword interact.
extends Node3D
class_name GameSequenceHandler

const SWORD_MAX_HP = 5
const BEARER_MAX_HP = 3
const OPPONENT_MAX_HP = 3

const NAMES = [
	"Attwell Haddock",
	"Siward Tothyll",
	"Humphrey Denys",
	"Odo Wensley",
	"Algar Leighlin",
	"Sewel Ballard",
	"Osgood Baker",
	"Bartholomew Westbrook",
	"Rollo Deryngton",
	"Thomas Sheffeld",
	"Margery Goodwyn",
	"Ragenhild Waldeley",
	"Ediva Cosworth",
	"Bridget Clement",
	"Godusa Theobauld",
	"Stanilde Redman",
	"Golde Playters",
	"Maud Fleet",
	"Charity Hungate",
	"Sarah Codington",
]

@export var swing_arm: SwingArm
@export var sword: Sword
@export var target: Target
@export var camera: MainCamera

@onready var main: Node3D = get_tree().current_scene

@onready var sword_hp_bar: ProgressBar = %SwordHealth
@onready var bearer_hp_bar: ProgressBar = %BearerHealth
@onready var opp_hp_bar: ProgressBar = %OpponentHealth

signal sequence_finished

var swinging = false
var sword_hp = SWORD_MAX_HP:
	set(value):
		sword_hp_bar.value = value
		sword_hp = value
var bearer_hp = BEARER_MAX_HP:
	set(value):
		bearer_hp_bar.value = value
		bearer_hp = value
var opp_hp = OPPONENT_MAX_HP:
	set(value):
		opp_hp_bar.value = value
		opp_hp = value


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_loop.call_deferred()
	sword_hp_bar.max_value = SWORD_MAX_HP
	bearer_hp_bar.max_value = BEARER_MAX_HP
	opp_hp_bar.max_value = OPPONENT_MAX_HP


func game_loop():
	%BearerName.text = NAMES.pick_random()
	%OpponentName.text = NAMES.pick_random()
	sword_hp_bar.value = SWORD_MAX_HP
	bearer_hp_bar.value = BEARER_MAX_HP
	opp_hp_bar.value = OPPONENT_MAX_HP
	while true:
		swing_sequence()
		await sequence_finished

		if opp_hp <= 0:
			%OpponentName.text = ""
			await get_tree().create_timer(0.5).timeout
			%NewChallenger.show()
			await get_tree().create_timer(2).timeout
			opp_hp = OPPONENT_MAX_HP
			%NewChallenger.hide()
			%OpponentName.text = NAMES.pick_random()

		for _i in range(randi_range(1, 2)):
			block_sequence()
			await sequence_finished
			if sword_hp <= 0:
				break
		if sword_hp <= 0:
			break
	%DeathScreen.show()


## Common actions that are done at the start of both swing and block sequences
func pre_sequence():
	target.move()
	attach_to_arm()
	swing_arm.randomize_swing_direction()


## Common actions that are done at the end of both swing and block sequences
func post_sequence():
	detach_from_arm()
	sequence_finished.emit()


func swing_sequence():
	target.red()
	pre_sequence()
	swing_arm.play_animation("windup")
	await swing_arm.swing_animation_player.animation_finished
	
	if swinging:
		# Successful hit
		swing_arm.play_animation("swing")
		await swing_arm.swing_animation_player.animation_finished
		swinging = false
		camera.shake(0.2, 15)
		target.hit_effect.restart()
		opp_hp -= 1
		sword_hp = SWORD_MAX_HP
	else:
		# Whiff
		swing_arm.play_animation("falter_swing")
		await swing_arm.swing_animation_player.animation_finished
	post_sequence()


func lock_swing():
	if not swing_arm.is_animation_playing("windup"):
		return
	# Check if inputs are correct
	swinging = sword.target_rotation == target.target_rot
	# Skip windup animation
	swing_arm.swing_animation_player.advance(INF)


func block_sequence():
	target.blue()
	pre_sequence()
	swing_arm.play_animation("block")
	await swing_arm.swing_animation_player.animation_finished
	if sword.is_correct_rotation():
		# Successful block
		camera.shake(0.2, 15)
		sword_hp -= 1
		print(sword_hp)
	else:
		# Failed block
		camera.shake(0.1, 6)
		sword.screen_color_animation.play("red_flash")
		bearer_hp -= 1
	post_sequence()


## Called when the sword first enters correct rotation. If blocking, complete
## the block. If attacking, play alignment animation.
func sword_entered_correct_rotation():
	if swing_arm.is_animation_playing("block"):
		swing_arm.swing_animation_player.advance(INF)
		target.block_effect.restart()
	else:
		target.align_effect.play("Sword_Aligned")


func attach_to_arm():
	# Preserve global position and rotation
	var pos = global_position
	var rot = global_rotation
	get_parent().remove_child(self)
	swing_arm.arm.add_child(self)
	global_position = pos
	global_rotation = rot


func detach_from_arm():
	# Reset global position to zero
	swing_arm.arm.remove_child(self)
	main.add_child(self)
	global_position = Vector3.ZERO
	global_rotation = Vector3.ZERO

func _on_respawn_button_pressed() -> void:
	%DeathScreen.hide()
	game_loop.call_deferred()
