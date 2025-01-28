## Acts as the sword origin, childs and dechilds from the swing arm.
## Parent of sword, target, camera.
## Handles main game loop and is the main way that the swing arm, target, camera,
## and sword interact.
extends Node3D
class_name GameSequenceHandler

@export var swing_arm: SwingArm
@export var sword: Sword
@export var target: Target
@export var camera: MainCamera

@onready var main: Node3D = get_tree().current_scene

enum ACTION {SWING, BLOCK}

signal sequence_finished

var PEASANT = CombatantRank.new(1, 2, 6)
var FOOTSOLDIER = CombatantRank.new(2, 4, 5)
var KNIGHT = CombatantRank.new(4, 8, 3)

var swinging = false
var action_queue: Array[ACTION]
var bearer_rank: CombatantRank
var opponent_rank: CombatantRank

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_loop.call_deferred()
	bearer_rank = PEASANT
	opponent_rank = KNIGHT

func game_loop():
	construct_action_queue()
	while true:
		var curr_action = action_queue.pop_front()
		match curr_action:
			ACTION.SWING:
				swing_sequence()
			ACTION.BLOCK:
				block_sequence()
		await sequence_finished
		action_queue.append(curr_action)


func construct_action_queue():
	action_queue.clear()
	for _i in range(bearer_rank.num_attacks):
		action_queue.append(ACTION.SWING)
	for _i in range(opponent_rank.num_attacks):
		action_queue.append(ACTION.BLOCK)


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
	
	sword.lock_input()
	if swinging:
		swing_arm.play_animation("swing")
		await swing_arm.swing_animation_player.animation_finished
		swinging = false
		camera.shake(0.2, 15)
		target.hit_effect.restart()
	else:
		target.hide()
		swing_arm.play_animation("falter_swing")
		await swing_arm.swing_animation_player.animation_finished
		target.show()
	sword.unlock_input()
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
		camera.shake(0.2, 15)
	else:
		camera.shake(0.1, 6)
		sword.screen_color_animation.play("red_flash")
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
