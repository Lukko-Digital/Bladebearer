extends Node3D

func move():
	var target_rot = Vector3(
		randi_range(-1, 1),
		0,
		randi_range(-1, 1)
	)
	target_rot *= 45
	if randi() % 2:
		target_rot.x *= 3
	
	rotation_degrees = target_rot
	print(rotation_degrees)