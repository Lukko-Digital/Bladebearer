@tool
extends Node3D

@export var lights: Array[Light3D]

@export var brightness: float = 1.0 :
	set(value):
		brightness = value
		for light in lights:
			light.light_energy = value