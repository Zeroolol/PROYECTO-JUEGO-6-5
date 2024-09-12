extends Node3D

@onready var player = $Player/CharacterBody3D

func _physics_process(delta):
	var player_position = player.global_transform.origin
	print("Posición del jugador:", player_position)
	get_tree().call_group("Enemy", "update_target_location", player_position)
