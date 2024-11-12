extends Node3D

var player

func _ready() -> void:
	player = get_node("/root/" + get_tree().current_scene.name + "/Player/CharacterBody3D")

func _process(delta: float) -> void:
	get_tree().call_group("monster", "update_target_location")
