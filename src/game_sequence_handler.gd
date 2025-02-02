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
@export var heart_border_ui: HeartBorderUI

@onready var main: Node3D = get_tree().current_scene

enum ACTION {SWING, BLOCK}

signal sequence_finished

var PEASANT = CombatantRank.new(1, 2, 2, CombatantRank.RankName.PEASANT)
var FOOTSOLDIER = CombatantRank.new(2, 4, 2, CombatantRank.RankName.FOOTSOLDIER)
var KNIGHT = CombatantRank.new(4, 8, 3, CombatantRank.RankName.KNIGHT)
var KINGSGUARD = CombatantRank.new(6, 12, 2, CombatantRank.RankName.KINGSGUARD)

# P = Peasant, F = Footsoldier, K = Knight, G = Kingsguard
# Space separated list of combatants in the location
# If multiple letters are adjacent, it is a randomized selection between them
const locations = {
    "Royal Tent": "G G",
    "Kingsguard": "KG K G",
    "Central Field": "FK FK FK K",
    "Rear Guard": "PF PF F K",
    "Straggler's Field": "F PF PF",
    "Outer Woods": "P P",
    "Deep Woods": "P P",
}

# Variables that control progress outsie of a single combat
var combatants: Array[CombatantRank]
var needed_wins: int
var current_location: String

# Variables that control top level of combat
var action_queue: Array[ACTION]
var bearer_rank: CombatantRank
var opponent_rank: CombatantRank

# Variables that actively change during combat
var swinging = false
var bearer_health: int
var opponent_health: int


var array_of_times: Array[float] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$WinCount.modulate = Color(Color.WHITE, 0)
	$NewBearer.modulate = Color(Color.WHITE, 0)
	# bearer_rank = PEASANT
	# init_bearer_health()
	# enter_location("Rear Guard")
	await get_tree().create_timer(1).timeout
	enter_combat.call_deferred()
	


func enter_combat():
	for i in range(15):
		block_sequence()
		await sequence_finished
	var total_time = 0
	for value in array_of_times:
		total_time += value
	print(total_time/15)
	sword.hide()
	await get_tree().create_timer(1).timeout
	get_tree().quit()

	# init_opponent()
	# construct_action_queue()
	# while true:
	# 	var curr_action = action_queue.pop_front()
	# 	match curr_action:
	# 		ACTION.SWING:
	# 			swing_sequence()
	# 		ACTION.BLOCK:
	# 			block_sequence()
	# 	await sequence_finished
	# 	action_queue.append(curr_action)

	# 	if opponent_health <= 0:
	# 		opponent_defeated()
	# 		break
	# 	if bearer_health <= 0:
	# 		bearer_defeated()
	# 		break


## ----------------- LOCATION LOGIC -----------------


func enter_location(location_name: String):
	current_location = location_name
	create_combatant_list(locations[location_name])
	needed_wins = combatants.size()


## last_n is used when the player changes bearer and is set back one combat,
## so the combatants are re-randomized
func create_combatant_list(combatant_string: String, last_n: int = 0):
	combatants.clear()
	for char_set in combatant_string.split(" ").slice(-last_n):
		var combatant_char = char_set[randi() % char_set.length()]
		match combatant_char:
			"P":
				combatants.append(PEASANT)
			"F":
				combatants.append(FOOTSOLDIER)
			"K":
				combatants.append(KNIGHT)
			"G":
				combatants.append(KINGSGUARD)


## ----------------- SINGLE COMBAT LOGIC -----------------


func init_bearer_health(starting_health: int = -1):
	if starting_health == -1:
		starting_health = bearer_rank.health

	bearer_health = bearer_rank.health
	bearer_heart_holder.set_hearts(bearer_health, starting_health)
	heart_border_ui.set_bearer_border(bearer_rank)


func init_opponent():
	opponent_rank = combatants.pop_front()
	opponent_health = opponent_rank.health
	opponent_heart_holder.set_hearts(opponent_health)
	heart_border_ui.set_opponent_border(opponent_rank)


func construct_action_queue():
	action_queue.clear()
	for _i in range(bearer_rank.num_attacks):
		action_queue.append(ACTION.SWING)
	for _i in range(opponent_rank.num_attacks):
		action_queue.append(ACTION.BLOCK)


func bearer_loses_health():
	bearer_health -= 1
	bearer_heart_holder.break_heart_at_idx(bearer_health)


func opponent_loses_health():
	opponent_health -= 1
	opponent_heart_holder.break_heart_at_idx(opponent_health)


func bearer_defeated():
	# Change hands, lose one location win, regen combatants
	var label = $NewBearer

	var tween_in = create_tween()
	tween_in.tween_property(label, "modulate", Color(Color.WHITE, 1), 2)
	await tween_in.finished
	
	await get_tree().create_timer(1).timeout

	var tween_out = create_tween()
	tween_out.tween_property(label, "modulate", Color(Color.WHITE, 0), 2)
	await tween_out.finished


	bearer_rank = opponent_rank
	init_bearer_health(opponent_health)
	create_combatant_list(
		locations[current_location],
		max( # Make sure it doesn't go negative
			# -2 because the size of combatants is one less that the number
			# of remaining fights, as combantants is popped at the start of
			# combat. Then we subtract 1 more because of the bearer defeat.
			needed_wins - combatants.size() - 2,
			0
		)
	)
	enter_combat()


func opponent_defeated():
	if combatants.is_empty():
		# Move to next location
		print("next location")
	else:
		# Slide out camera, update kill count, slide camera back, enter next combat

		# Hide combat stuff
		target.holo_red.hide() # Holo red will be showing because you have to win on a hit
		opponent_heart_holder.hide()
		heart_border_ui.opponent_borders.hide()

		# Animation sequence
		await get_tree().create_timer(1).timeout
		var count_label = $WinCount

		camera.slide(true)
		await camera.slide_finished

		var tween_in = create_tween()
		tween_in.tween_property(count_label, "modulate", Color(Color.WHITE, 1), 2)
		await tween_in.finished
		
		## LOCATION PROGRESSION
		await get_tree().create_timer(1).timeout
		count_label.text = str(needed_wins - combatants.size()) + "/" + str(needed_wins)
		await get_tree().create_timer(1).timeout

		## SPAWN IN UPGRADE CHOICE
		## tbd

		## ON PICK UPGRADE
		sword.clear_blood()

		var tween_out = create_tween()
		tween_out.tween_property(count_label, "modulate", Color(Color.WHITE, 0), 2)
		await tween_out.finished
		
		camera.slide(false)
		await camera.slide_finished

		await get_tree().create_timer(1).timeout

		# Show combat stuff
		opponent_heart_holder.show()
		heart_border_ui.opponent_borders.show()
		enter_combat()


## ----------------- PLAYER INPUT -----------------


func lock_swing():
	if not swing_arm.is_animation_playing("windup"):
		return
	# Check if inputs are correct
	swinging = sword.target_rotation == target.target_rot
	# Skip windup animation
	swing_arm.swing_animation_player.advance(INF)


## Called when the sword first enters correct rotation. If blocking, complete
## the block. If attacking, play alignment animation.
func sword_entered_correct_rotation():
	if swing_arm.is_animation_playing("block"):
		swing_arm.swing_animation_player.advance(INF)
		target.block_effect.restart()
	else:
		target.align_effect.play("Sword_Aligned")


## ----------------- SEQUENCES -----------------


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
	swing_arm.play_animation("windup", opponent_rank.time_to_react)
	target.play_animation("Blink", opponent_rank.time_to_react)
	await swing_arm.swing_animation_player.animation_finished
	
	sword.lock_input()
	if swinging:
		# Successful swing
		swing_arm.play_animation("swing")
		
		Global.sfx_player.play("Yell")
		Global.sfx_player.play_timed("Woosh", 0.1)

		await swing_arm.swing_animation_player.animation_finished
		Global.sfx_player.play("Sword_Hit")
		swinging = false
		camera.shake(0.2, 15)
		target.hit_effect.restart()
		opponent_loses_health()
		sword.add_blood()
	else:
		# No swing
		target.hide()
		swing_arm.play_animation("falter_swing")
		await swing_arm.swing_animation_player.animation_finished
		target.show()
	sword.unlock_input()
	post_sequence()




func block_sequence():
	target.blue()
	pre_sequence()
	var start_time = Time.get_ticks_msec()
	swing_arm.play_animation("block", 1000)
	target.play_animation("Blink", 1000)
	await swing_arm.swing_animation_player.animation_finished
	if sword.is_correct_rotation():
		# Successful block
		Global.sfx_player.play("Sword_Hit")
		camera.shake(0.2, 15)
		# print(Time.get_ticks_msec() - start_time)
		array_of_times.append(Time.get_ticks_msec() - start_time)
		# Global.sfx_player.play("Test")
	else:
		# Failed block
		camera.shake(0.1, 6)
		sword.screen_color_animation.play("red_flash")
		bearer_loses_health()
	post_sequence()


## ----------------- ARM INTERACTION -----------------


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
