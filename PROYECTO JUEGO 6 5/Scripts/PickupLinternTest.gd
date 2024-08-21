extends StaticBody3D

var flashlight

func _ready():
	# Usa `current_scene` en lugar de `current.scene`
	flashlight = get_node("/root/" + get_tree().current_scene.name + "/Player/CharacterBody3D/Cabeza/Camera3D/FlashLight")

func interact():
	flashlight.picked_up = true
	queue_free()  # Elimina la linterna de la escena después de recogerla
