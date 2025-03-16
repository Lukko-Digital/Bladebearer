@tool
extends Node3D
class_name Target

@export var sword: Sword
@export var swing_arm: SwingArm

@onready var holo_blue: Node3D = %HologramBlue
@onready var holo_red: Node3D = %HologramRed

@onready var block_effect: Node3D = %BlockEffect
@onready var hit_effect: Node3D = %HitEffect
@onready var align_effect: AnimationPlayer = %AlignEffect

@export var meshes: Array[GeometryInstance3D]
@export_range(0, 1) var transparency: float = 0.0:
	set(value):
		transparency = value
		for mesh in meshes:
			mesh.transparency = value

@onready var target_animation_player: AnimationPlayer = %TargetAnimationPlayer

enum ShiftState {NEVER, RANDOM, ALWAYS}

const ROTATION_LERP_SPEED = 4

var target_rot: Vector3
var last_action: GameSequenceHandler.Action
# Control variable for footsoldier and knight to decide if they should invert and generate a new position
var flip_previous: bool = false

func _process(delta: float) -> void:
	var target_position : Vector3
	var usable_rot : Vector3 = target_rot
	if (target_rot.x > 45 || target_rot.z > 45 || target_rot.x < -45 || target_rot.z < -45):
		usable_rot.x = wrapf(180 + target_rot.x, -180, 180)
		target_position = usable_rot / Sword.ROTATION_ANGLE
		target_position.x = -1 * target_position.x
	else: target_position = usable_rot / Sword.ROTATION_ANGLE
	if round(rotation_degrees) != target_rot:
		rotation.x = wrapf(lerp_angle(rotation.x, deg_to_rad(target_rot.x), ROTATION_LERP_SPEED * delta), -PI, PI)
		rotation.z = wrapf(lerp_angle(rotation.z, deg_to_rad(target_rot.z), ROTATION_LERP_SPEED * delta), -PI, PI)
	position.x = lerp(position.x, target_position.z * -0.4, ROTATION_LERP_SPEED * delta)
	position.z = lerp(position.z, target_position.x * 0.3, ROTATION_LERP_SPEED * delta)

## Rank is bearer rank if swinging, opponent rank if blocking
func move(
	attacker_rank: CombatantRank.RankName,
	action: GameSequenceHandler.Action,
	predefined_location: Vector3 = Vector3.INF
):
	if predefined_location != Vector3.INF:
		target_rot = predefined_location
		swing_arm.move_to_swing_position(target_rot)
		return
	
	if action == GameSequenceHandler.Action.SWING:
		# ATTACKS
		if attacker_rank == CombatantRank.RankName.PEASANT:
			# PEASANTS NO SHIFT ATTACK
			target_rot = randomize_rotation(ShiftState.NEVER)
		else:
			target_rot = randomize_rotation()
	else:
		match attacker_rank:
			CombatantRank.RankName.PEASANT:
				target_rot = randomize_rotation(ShiftState.NEVER)
			CombatantRank.RankName.FOOTSOLDIER:
				target_rot = footsoldier()
			CombatantRank.RankName.KNIGHT:
				target_rot = knight()
			CombatantRank.RankName.KINGSGUARD:
				target_rot = randomize_rotation()
			
	last_action = action
	swing_arm.move_to_swing_position(target_rot)

## -------------------------- MAIN RANDOMIZE --------------------------

func randomize_rotation(shift_state: ShiftState = ShiftState.RANDOM) -> Vector3:
	var new_rot: Vector3
	while true:
		# Loop until rotation satisfies `is_valid_new_rotation`.
		new_rot = Vector3(
			randi_range(-1, 1),
			0,
			rand_sign() # Require left or right rotation
		)
		new_rot *= 45

		match shift_state:
			ShiftState.ALWAYS:
				new_rot = apply_shift(new_rot)
			ShiftState.RANDOM:
				if randi() % 2:
					new_rot = apply_shift(new_rot)
			ShiftState.NEVER:
				pass

		if is_valid_new_rotation(new_rot):
			return new_rot
	return Vector3.ZERO

## -------------------------- BY RANK --------------------------

func footsoldier() -> Vector3:
	if not flip_previous or last_action == GameSequenceHandler.Action.SWING: # <-- if new block sequence
		flip_previous = true
		return randomize_rotation(ShiftState.NEVER)
	else:
		flip_previous = false
		return apply_shift(target_rot)


func knight() -> Vector3:
	if not flip_previous or last_action == GameSequenceHandler.Action.SWING: # <-- if new block sequence
		flip_previous = true
		return randomize_rotation(ShiftState.RANDOM)
	else:
		flip_previous = false
		return Vector3(
			wrapf(target_rot.x - 180, -180, 180),
			0,
			-target_rot.z
		)

## -------------------------- HELPERS --------------------------

func apply_shift(rot_degrees: Vector3) -> Vector3:
	return Vector3(
		wrapf(180 - rot_degrees.x, -180, 180),
		rot_degrees.y,
		rot_degrees.z
	)

# Randomly returns -1 or 1
func rand_sign() -> int:
	if randi() % 2:
		return -1
	return 1

func rotation_uses_shift(rot: Vector3) -> bool:
	return abs(rot.x) > 45

# Invalid rotations:
# 	- (0,0,0)
# 	- the same target twice in a row
# 	- 0 z rotation twice in a row
func is_valid_new_rotation(new_rot: Vector3) -> bool:
	return (
		new_rot != target_rot and
		new_rot != Vector3.ZERO and
		(target_rot.z != 0 or new_rot.z != 0)
	)

## -------------------------- VISUALS --------------------------

func red():
	holo_red.show()
	holo_blue.hide()

func blue():
	holo_blue.show()
	holo_red.hide()

func play_animation(animation_name: String, animation_duration: float = 0):
	target_animation_player.stop()
	assert(target_animation_player.has_animation(animation_name))

	if animation_duration > 0:
		target_animation_player.speed_scale = target_animation_player.get_animation(animation_name).length / animation_duration
	else:
		target_animation_player.speed_scale = 1

	target_animation_player.play(animation_name)
