extends Node3D

@onready var aula_area: Area3D = get_node("/root/TestingWorld/AulaArea")  # Área que define el aula

func _ready():
	$"animacion escena".play("comienzo")
	$"camara escena".current = true

	await get_tree().create_timer(9.0, false).timeout

	var player = get_node("/root/TestingWorld/Player/CharacterBody3D")
	player.movable = true
	player.get_node("Cabeza/Camera3D").current = true
	$"camara escena".current = false
