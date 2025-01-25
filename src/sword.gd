extends Node3D

const ROTATION_LERP_SPEED = 0.2

@export var target_ball: Node3D

@onready var sword_mesh: MeshInstance3D = $SwordMesh

var target_rotation = Vector3()

func _ready() -> void:
	target_ball.move()

func _process(_delta: float) -> void:
	target_rotation = Vector3()
	target_rotation.x = Input.get_axis("forward", "backward")
	target_rotation.z = Input.get_axis("right", "left")
	target_rotation *= 45
	if Input.is_action_pressed("shift"):
		target_rotation.x *= 3

	var yaw = 0.0
	if Input.is_action_pressed("space"):
		yaw = 90.0
	sword_mesh.rotation_degrees.y = lerp(sword_mesh.rotation_degrees.y, yaw, ROTATION_LERP_SPEED)

	rotation_degrees = rotation_degrees.lerp(target_rotation, ROTATION_LERP_SPEED)
	
	if round(rotation_degrees) == round(target_ball.rotation_degrees):
		target_ball.move()
