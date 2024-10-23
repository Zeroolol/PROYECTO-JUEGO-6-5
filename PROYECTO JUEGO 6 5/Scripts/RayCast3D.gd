extends RayCast3D 

var int_text
var jugador  # Referencia al jugador
var keypad_instance  # Instancia del keypad

@onready var keypad_scene = preload("res://Escenas/keypad.tscn")  # Ruta del recurso del keypad

func _ready():
	int_text = get_node("/root/" + get_tree().current_scene.name + "/UI/interact_text")
	jugador = get_node("/root/TestingWorld/Player/CharacterBody3D")  # Asegúrate de tener la referencia correcta al jugador

func _process(delta):
	if is_colliding():
		var hit = get_collider()
		if hit.has_method("interact"):
			int_text.visible = true
			if Input.is_action_just_pressed("Interact"):
				int_text.visible = false  # Ocultar texto de interacción
				
				# Verifica si la puerta pertenece al grupo exclusivo del keypad
				if hit.is_in_group("puertakeypad"):  # Verifica si es la puerta del grupo exclusivo
					if not keypad_instance:  # Si no hay una instancia ya creada
						keypad_instance = keypad_scene.instantiate()  # Instanciar el keypad
						get_tree().current_scene.add_child(keypad_instance)  # Agregar el keypad a la escena
					keypad_instance.show_keypad(jugador, hit)  # Mostrar el keypad y pasar la puerta
				else:
					# Si no es una puerta del keypad, interactúa normalmente
					hit.interact(jugador)  # Llama a la función interact de la puerta normal
		else:
			int_text.visible = false
	else:
		int_text.visible = false
