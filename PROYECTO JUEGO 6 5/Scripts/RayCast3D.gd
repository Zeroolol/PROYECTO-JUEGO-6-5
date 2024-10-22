extends RayCast3D

var int_text
var jugador  # Referencia al jugador

func _ready():
	int_text = get_node("/root/" + get_tree().current_scene.name + "/UI/interact_text")
	jugador = get_node("/root/TestingWorld/Player/CharacterBody3D")  # Asegúrate de tener la referencia correcta al jugador

func _process(delta):
	if is_colliding():
		var hit = get_collider()
		if hit.has_method("interact"):
			int_text.visible = true
			if Input.is_action_just_pressed("Interact"):
				hit.interact(jugador)  # Pasamos el jugador como parámetro
		else:
			int_text.visible = false
	else:
		int_text.visible = false
