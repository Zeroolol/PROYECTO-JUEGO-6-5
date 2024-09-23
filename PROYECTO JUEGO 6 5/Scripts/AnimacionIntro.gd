extends Node3D

func _ready():
	$"AnimacionIntro".play("Introduccion")
	$"Camara Intro".current = true
	await get_tree().create_timer(12.8, false).timeout
	get_node("/root/" + get_tree().current_scene.name + "/Player/CharacterBody3D").movable = true
	get_node("/root/" + get_tree().current_scene.name + "/Player/CharacterBody3D/Cabeza/Camera3D").current = true
	$"Camara Intro".current = false
	queue_free()

