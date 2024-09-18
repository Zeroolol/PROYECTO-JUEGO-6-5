extends CanvasLayer

func _ready():
	# Mostrar el cursor y liberar el mouse para permitir la interacción con la UI
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	var retry_button = $VBoxContainer/Reintentar
	var exit_button = $VBoxContainer/Salir

	if retry_button and exit_button:
		retry_button.connect("pressed", Callable(self, "_on_retry_button_pressed"))
		exit_button.connect("pressed", Callable(self, "_on_exit_button_pressed"))
	else:
		print("Error: No se encuentran los botones Reintentar o Salir.")

func _on_retry_button_pressed():
	# Reiniciar el juego, cargando la escena principal
	get_tree().change_scene_to_file("res://Escenas/testing_world.tscn")  # Asegúrate de poner la ruta correcta de tu escena principal

	# Ocultar el cursor nuevamente y capturar el mouse para el control del juego
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_exit_button_pressed():
	# Cerrar el juego o volver al menú principal
	get_tree().change_scene_to_file("res://Escenas/Menu.tscn")

	# El mouse ya está visible en el menú, así que no necesitamos hacer nada más aquí
