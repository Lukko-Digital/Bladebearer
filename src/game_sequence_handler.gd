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

signal sequence_finished

var swinging = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_loop.call_deferred()


func game_loop():
	while true:
		# 50/50 block or attack
		if randi() % 2:
			target.red()
			for _i in range(randi_range(1, 1)):
				target.move()
				swing_sequence()
				await sequence_finished
		else:
			target.blue()
			for _i in range(randi_range(1, 2)):
				target.move()
				block_sequence()
				await sequence_finished


func swing_sequence():
	attach_to_arm()
	swing_arm.randomize_swing_direction()

	swing_arm.play_animation("windup")
	await swing_arm.swing_animation_player.animation_finished
	
	if swinging:
		swing_arm.play_animation("swing")
		await swing_arm.swing_animation_player.animation_finished
		swinging = false
		camera.shake(0.2, 15)
		target.hit_effect.restart()
	else:
		swing_arm.play_animation("falter_swing")
		await swing_arm.swing_animation_player.animation_finished
	
	detach_from_arm()
	sequence_finished.emit()


func lock_swing():
	if not swing_arm.is_animation_playing("windup"):
		return
	# Check if inputs are correct
	swinging = sword.target_rotation == target.target_rot
	# Skip windup animation
	swing_arm.swing_animation_player.advance(INF)


func block_sequence():
	attach_to_arm()
	swing_arm.randomize_swing_direction()

	swing_arm.play_animation("block")
	await swing_arm.swing_animation_player.animation_finished
	if sword.is_correct_rotation():
		camera.shake(0.2, 15)
	else:
		camera.shake(0.1, 6)
		sword.screen_color_animation.play("red_flash")
	
	detach_from_arm()
	sequence_finished.emit()


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
