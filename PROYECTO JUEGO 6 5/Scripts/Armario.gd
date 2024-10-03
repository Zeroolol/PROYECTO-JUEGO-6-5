extends Node3D

var is_open: bool = false
var original_player_position: Vector3

func interact():
	if is_open:
		close_armario()
	else:
		open_armario()

func open_armario():
	# Abre el armario (puedes añadir aquí la animación)
	is_open = true
	# Guarda la posición original del jugador
	original_player_position = get_parent().get_node("Player").global_position
	# Coloca al jugador dentro del armario
	get_parent().get_node("Player").global_position = global_position + Vector3(0, 0, -1)  # Ajusta la posición

func close_armario():
	# Cierra el armario (puedes añadir aquí la animación)
	is_open = false
	# Devuelve al jugador a su posición original
	get_parent().get_node("Player").global_position = original_player_position
