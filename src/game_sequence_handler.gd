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
@export var bearer_heart_holder: HeartHolder
@export var opponent_heart_holder: HeartHolder
@export var dialogue_handler: DialogueHandler

@onready var main: Node3D = get_tree().current_scene

enum ACTION {SWING, BLOCK}

signal sequence_finished

var PEASANT = CombatantRank.new(1, 2, 6)
var FOOTSOLDIER = CombatantRank.new(2, 4, 5)
var KNIGHT = CombatantRank.new(4, 8, 3)

# Variables that control top level of combat
var action_queue: Array[ACTION]
var bearer_rank: CombatantRank
var opponent_rank: CombatantRank

# Variables that actively change during combat
var swinging = false
var bearer_health: int
var opponent_health: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bearer_rank = KNIGHT
	opponent_rank = KNIGHT
	start_dialogue()
	# game_loop.call_deferred()

func game_loop():
	init_fight()
	while true:
		var curr_action = action_queue.pop_front()
		match curr_action:
			ACTION.SWING:
				swing_sequence()
			ACTION.BLOCK:
				block_sequence()
		await sequence_finished
		action_queue.append(curr_action)


func init_fight():
	bearer_health = bearer_rank.health
	opponent_health = opponent_rank.health
	bearer_heart_holder.set_hearts(bearer_health)
	opponent_heart_holder.set_hearts(opponent_health)
	construct_action_queue()


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


func bearer_loses_health():
	bearer_health -= 1
	bearer_heart_holder.break_heart_at_idx(bearer_health)


func opponent_loses_health():
	opponent_health -= 1
	opponent_heart_holder.break_heart_at_idx(opponent_health)


func swing_sequence():
	target.red()
	pre_sequence()
	swing_arm.play_animation("windup", opponent_rank.time_to_react)
	await swing_arm.swing_animation_player.animation_finished
	
	sword.lock_input()
	if swinging:
		# Successful swing
		swing_arm.play_animation("swing")
		await swing_arm.swing_animation_player.animation_finished
		swinging = false
		camera.shake(0.2, 15)
		target.hit_effect.restart()
		opponent_loses_health()
	else:
		# No swing
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
	swing_arm.play_animation("block", opponent_rank.time_to_react)
	await swing_arm.swing_animation_player.animation_finished
	if sword.is_correct_rotation():
		# Successful block
		camera.shake(0.2, 15)
	else:
		# Failed block
		camera.shake(0.1, 6)
		sword.screen_color_animation.play("red_flash")
		bearer_loses_health()
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

func start_dialogue():
	target.hide()
	dialogue_handler.start_dialogue(["aasd", "bfds", "cgre"])