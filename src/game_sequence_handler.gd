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
@export var dialogue_handler: DialogueHandler
@export var locations_wheel: LocationsWheel
@export var location_hearts: HeartHolder
@export var credits: Node3D

@onready var cam_anim: AnimationPlayer = %FinalCameraAnimator

@onready var main: Node3D = get_tree().current_scene

@onready var sword_animator: AnimationPlayer = %SwordAnimator
@onready var snow: GPUParticles3D = %Snow
@onready var opponent_approach_label: OpponentApproachLabel = %OpponentApproachLabel
@onready var tutorial_label: CombatTutorialLabel = %CombatTutorialLabel
@onready var bearer_death_animator: AnimationPlayer = %BearerDeathAnimator
@onready var ground: Node3D = %Ground

enum Action {SWING, BLOCK}

signal sequence_finished

var PEASANT = CombatantRank.new(1, 2, 2, 4, CombatantRank.RankName.PEASANT)
var FOOTSOLDIER = CombatantRank.new(2, 4, 4, 4, CombatantRank.RankName.FOOTSOLDIER)
var KNIGHT = CombatantRank.new(3, 6, 8, 3, CombatantRank.RankName.KNIGHT)
var KINGSGUARD = CombatantRank.new(4, 8, 12, 2, CombatantRank.RankName.KINGSGUARD)
var KING = CombatantRank.new(0, 0, 1, 999, CombatantRank.RankName.KING)

# P = Peasant, F = Footsoldier, K = Knight, G = Kingsguard, W = King (for Win and 王)
# Space separated list of combatants in the location
# If multiple letters are adjacent, it is a randomized selection between them
const locations = {
	"Royal Tent": "W",
	"Kingsguard": "G G",
	"Central Field": "FK FK K",
	"Rear Guard": "F K",
	"Straggler's Field": "F F",
	"Outer Woods": "P F",
	"Deep Woods": "P",
}

# Variables that control progress outsie of a single combat
var combatants: Array[CombatantRank]
var needed_wins: int
var current_location: int

# Variables that control top level of combat
var action_queue: Array[Action]
var bearer_rank: CombatantRank
var opponent_rank: CombatantRank

# Variables that actively change during combat
var swinging = false
var bearer_health: int
var opponent_health: int

var shift_taught = false

# Called when the node enters the scene tree for the first time. !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
func _ready() -> void:

	locations_wheel.hide()
	target.hide()

	await dialogue_handler.tutorial()
	await get_tree().create_timer(1).timeout

	await dialogue_handler.menu()

	Global.sfx_player.transition_volume_db("PreIntroAmbience", -16, 0.5)
	await dialogue_handler.intro()

	$NewBearer.modulate = Color(Color.WHITE, 0)
	$NewBearer.hide()
	bearer_rank = PEASANT
	init_bearer_health()
	enter_location(6)
	locations_wheel.set_location(6)
	enter_combat.call_deferred(true)

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

func enter_combat(first_combat: bool = false):

	Global.sfx_player.pick_music(false, true, false, 0.5)

	target.show()
	init_opponent()
	construct_action_queue()

	if first_combat:
		# Only happens on the first ever combat
		if dialogue_handler.kill:
			# If you choose "kill him"
			swing_sequence(true)
			await sequence_finished
			block_sequence(true)
			await sequence_finished
		else:
			# If you choose "im okay"
			block_sequence(true)
			await sequence_finished
			swing_sequence(true)
			await sequence_finished
			action_queue.reverse() # flip action queue so you block first
			
	while true:
		var curr_action = action_queue.pop_front()
		match curr_action:
			Action.SWING:
				swing_sequence()
			Action.BLOCK:
				block_sequence()
		await sequence_finished
		action_queue.append(curr_action)

		if opponent_health <= 0:
			opponent_defeated()
			Global.sfx_player.pick_music(true, false, false, 0.5)
			break
		if bearer_health <= 0:
			bearer_defeated()
			Global.sfx_player.pick_music(true, false, false, 0.5)
			break


## ----------------- LOCATION LOGIC -----------------


func enter_location(location_idx: int):
	current_location = location_idx
	create_combatant_list(locations[locations.keys()[location_idx]])
	needed_wins = combatants.size()
	location_hearts.set_hearts(needed_wins)


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
			"W":
				combatants.append(KING)


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
	for _i in range(bearer_rank.player_attacks):
		action_queue.append(Action.SWING)
	for _i in range(opponent_rank.num_attacks):
		action_queue.append(Action.BLOCK)


func bearer_loses_health():
	bearer_health -= 1
	bearer_heart_holder.break_heart_at_idx(bearer_health)


func opponent_loses_health():
	opponent_health -= 1
	opponent_heart_holder.break_heart_at_idx(opponent_health)


func bearer_defeated():
	target.holo_blue.hide() # Holo blue will be showing because you have to lose missing a block
	bearer_heart_holder.hide()
	heart_border_ui.bearer_borders.hide()

	# DROP ANIMATION
	ground.show()
	bearer_death_animator.play("drop")
	await bearer_death_animator.animation_finished
	# camera.shake(0.2, 15)

	# SLIDE OUT
	await get_tree().create_timer(0.5).timeout
	await camera.slide(true)

	# LOSE MESSSAGE
	var lose_message = opponent_approach_label.randomize_lose_message()
	await opponent_approach_label.fade_in(0.6, lose_message)
	await get_tree().create_timer(0.8).timeout
	await opponent_approach_label.fade_out(0.6)

	# LOCATION TICK BACK

	# FADE IN LOCATION
	locations_wheel.show()
	var fade_in_time = 0.5
	locations_wheel.fade_in(fade_in_time)
	location_hearts.fade_in(fade_in_time)
	await get_tree().create_timer(fade_in_time).timeout
	
	# RESET LOCATION
	location_hearts.fade_out(0.5)
	await get_tree().create_timer(0.5).timeout
	enter_location(current_location)
	location_hearts.fade_in(0.7)
	await get_tree().create_timer(0.7).timeout

	# FADE OUT LOCATION WHEEL
	var fade_out_time = 0.5
	locations_wheel.fade_out(fade_out_time)
	location_hearts.fade_out(fade_out_time)
	await get_tree().create_timer(fade_out_time).timeout
	locations_wheel.hide()
	
	# PICKUP
	bearer_death_animator.play("pickup")
	camera.shake(0.1, 10)
	await bearer_death_animator.animation_finished
	ground.hide()

	# CLEAR BLOOD
	sword.clear_blood()

	# A NEW BEARER, HEARTS TRANSFER
	bearer_rank = opponent_rank
	init_bearer_health(opponent_health)
	await opponent_heart_holder.transfer_hearts(bearer_heart_holder.position.y)

	opponent_heart_holder.hide()
	opponent_heart_holder.reset_y()
	bearer_heart_holder.show()

	heart_border_ui.bearer_borders.show()
	heart_border_ui.opponent_borders.hide()

	await opponent_approach_label.fade_in(1, "a new bearer claims the sword")
	await get_tree().create_timer(1).timeout
	await opponent_approach_label.fade_out(1)

	await opponent_approach_label.fade_in(1, "the battle rages on")
	await get_tree().create_timer(1).timeout
	await opponent_approach_label.fade_out(1)
	
	# SLIDE IN
	await camera.slide(false)
	await get_tree().create_timer(1).timeout

	opponent_heart_holder.show()
	heart_border_ui.opponent_borders.show()
	enter_combat()


func opponent_defeated():
	# Slide out camera, update location wheel and hearts, slide camera back, enter next combat

	# Hide combat stuff
	target.holo_red.hide() # Holo red will be showing because you have to win on a hit
	opponent_heart_holder.hide()
	heart_border_ui.opponent_borders.hide()
	
	if current_location == 0 and combatants.is_empty():
		win_sequence()
		return

	# SLIDE OUT
	await get_tree().create_timer(1).timeout
	await camera.slide(true)

	# SHOW WIN MESSAGE AFTER BATTLE
	var win_message = opponent_approach_label.randomize_win_message()
	await opponent_approach_label.fade_in(1, win_message)
	await get_tree().create_timer(1).timeout
	await opponent_approach_label.fade_out(1)

  # indicate player walking to new location
	Global.sfx_player.transition_volume_db("Walking", -25, 1)

	# FADE IN
	locations_wheel.show()
	var fade_in_time = 2
	locations_wheel.fade_in(fade_in_time)
	location_hearts.fade_in(fade_in_time)
	await get_tree().create_timer(fade_in_time).timeout
	
	## LOCATION PROGRESSION
	await get_tree().create_timer(1).timeout
	location_hearts.break_heart_at_idx(combatants.size())

	if combatants.is_empty():
		# Location completed, go next
		await locations_wheel.advance_location()
		enter_location(current_location - 1)
		location_hearts.fade_in(1)
		await get_tree().create_timer(1).timeout

	await get_tree().create_timer(0.5).timeout

	## CLEAR BLOOD
	sword.clear_blood()

	# FADE OUT LOCATION WHEEL
	var fade_out_time = 1
	locations_wheel.fade_out(fade_out_time)
	location_hearts.fade_out(fade_out_time)
	await get_tree().create_timer(fade_out_time).timeout
	locations_wheel.hide()

	# SHOW OPPONENT APPROACH LABEL
	var description = opponent_approach_label.randomize_description(opponent_rank.name)
	await opponent_approach_label.fade_in(1, description)
	await get_tree().create_timer(1).timeout
	await opponent_approach_label.fade_out(1)

	# Player has arrived
	Global.sfx_player.transition_volume_db("Walking", -80.0, 3)
	
	# SLIDE IN
	await camera.slide(false)
	await get_tree().create_timer(1).timeout

	# Show combat stuff
	opponent_heart_holder.show()
	heart_border_ui.opponent_borders.show()
	enter_combat()

@export var king_begging: AudioStreamPlayer
@export var kill_king: AudioStreamPlayer
@export var spare_king: AudioStreamPlayer

func win_sequence():
	bearer_heart_holder.hide()
	heart_border_ui.bearer_borders.hide()
	king_begging.play()
	Global.sfx_player.pick_music(1, 0, 0, 1.0, -30)
	
	dialogue_handler.king_scene()
	dialogue_handler.king_outcome.connect(win_seq2)
	await dialogue_handler.king_outcome

func win_seq2(killed: bool):
	snow.hide()
	sword.hide()
	if killed:
		Global.sfx_player.play("Stick_Break")
		await get_tree().create_timer(0.6).timeout
		kill_king.play()
		await get_tree().create_timer(1.6).timeout
		Global.sfx_player.play("Sword_Hit_Person")
	else:
		Global.sfx_player.play("Sword_Hit_Person")
		Global.sfx_player.play("Human_Getting_Hit_Foreal")
		await get_tree().create_timer(2.6).timeout
		spare_king.play()
	
	await dialogue_handler.credits
	# await camera.slide(true)
	Global.sfx_player.pick_music(0, 1, 0, 0.2)
	sword.show()
	# -------------------- JOSH CREDITS GO HERE RIGHT HERE PLACE THEM HERE --------------------
	credits.show()
	cam_anim.play("new_animation")
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

## Slow snow to a stop
func freeze_snow():
	snow.interpolate = false
	swing_arm.arm_animation_player.speed_scale = 0
	var tween = create_tween()
	tween.tween_property(snow, "speed_scale", 0, 1.2).set_trans(Tween.TRANS_QUAD)
	await tween.finished

func resume_snow():
	snow.interpolate = true
	snow.speed_scale = 1
	swing_arm.arm_animation_player.speed_scale = 1

## Common actions that are done at the start of both swing and block sequences
func pre_sequence(
	attacker_rank: CombatantRank.RankName,
	action: Action,
	predefined_location: Vector3 = Vector3.INF
):
	target.move(attacker_rank, action, predefined_location)
	attach_to_arm()
	swing_arm.randomize_swing_direction()


## Common actions that are done at the end of both swing and block sequences
func post_sequence():
	detach_from_arm()
	sequence_finished.emit()


func swing_sequence(first_swing: bool = false):
	target.red()

	if first_swing:
		# Only used on the first ever swing of the game, plays swing tutorial
		pre_sequence(bearer_rank.name, Action.SWING, Vector3(-45, 0, 45))
		sword.lock_input()
		await freeze_snow()
		sword.unlock_input()
		tutorial_label.attack()
		swing_arm.play_animation("windup", 999) # this value does need to be a finite number
		await swing_arm.swing_animation_player.animation_finished
		resume_snow()
		tutorial_label.hide()
	else:
		pre_sequence(bearer_rank.name, Action.SWING)
		swing_arm.play_animation("windup", opponent_rank.time_to_react)
		target.play_animation("Blink", opponent_rank.time_to_react)
		await swing_arm.swing_animation_player.animation_finished

	sword.lock_input()
	if swinging:
		# Successful swing
		swing_arm.play_animation("swing")
		
		Global.sfx_player.play_random("Swing_Grunt_Group")
		Global.sfx_player.play_timed("Woosh", 0.1)

		await swing_arm.swing_animation_player.animation_finished
		Global.sfx_player.play("Sword_Hit_Person")
		Global.sfx_player.play_random("Getting_Hit_Group_Opp")
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
	# Global.sfx_player.play_random("Footsteps_Group", randi_range(0, 2))
	post_sequence()


func block_sequence(first_block: bool = false):
	target.blue()

	if first_block:
		# Only used on the first ever block of the game
		pre_sequence(opponent_rank.name, Action.BLOCK, Vector3(-45, 0, -45))
		sword.lock_input()
		await freeze_snow()
		sword.unlock_input()
		tutorial_label.block()
		swing_arm.play_animation("block", 999) # this value does need to be a finite number
		await swing_arm.swing_animation_player.animation_finished
		resume_snow()
		tutorial_label.hide()
	elif opponent_rank == FOOTSOLDIER and not shift_taught:
		pre_sequence(opponent_rank.name, Action.BLOCK, Vector3(135, 0, 45))
		sword.lock_input()
		await freeze_snow()
		sword.unlock_input()
		tutorial_label.shift()
		swing_arm.play_animation("block", 999) # this value does need to be a finite number
		await swing_arm.swing_animation_player.animation_finished
		resume_snow()
		tutorial_label.hide()
		shift_taught = true
	else:
		pre_sequence(opponent_rank.name, Action.BLOCK)
		swing_arm.play_animation("block", opponent_rank.time_to_react)
		target.play_animation("Blink", opponent_rank.time_to_react)
		await swing_arm.swing_animation_player.animation_finished

	if sword.is_correct_rotation():
		# Successful block
		Global.sfx_player.play_random("Swing_Grunt_Group_Opp")
		Global.sfx_player.play_random("Sword_Hit_Group")
		Global.sfx_player.play_random("Breathing_Group", randi_range(0, 2))
		camera.shake(0.2, 15)
		swing_arm.play_animation("land_block", 0, true)
		sword_animator.stop()
		sword_animator.play("land_block")
		# Global.sfx_player.play("Test")
	else:
		# Failed block
		camera.shake(0.1, 6)
		sword.screen_color_animation.play("red_flash")
		Global.sfx_player.play_random("Getting_Hit_Group")
		bearer_loses_health()
	# Global.sfx_player.play_random("Footsteps_Group", randi_range(0, 2))
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
