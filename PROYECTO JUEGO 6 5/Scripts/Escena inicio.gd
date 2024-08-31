extends Node3D

func _ready():
	$"animacion escena".play("comienzo")
	$"camara escena".current = true
	await get_tree().create_timer(9.0, false).timeout
	get_node("/root/" + get_tree().current_scene.name + "/Player/CharacterBody3D").movable = true
	get_node("/root/" + get_tree().current_scene.name + "/Player/CharacterBody3D/Cabeza/Camera3D").current = true
	$"camara escena".current = false
	queue_free()
