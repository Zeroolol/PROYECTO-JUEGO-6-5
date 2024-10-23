extends StaticBody3D

var interactable = true
var opened = false
var key_item_name = "LlaveLab0"  # Nombre de la llave requerida
@export var required_key: String = "LlaveLab0"  # Nombre de la llave requerida

func interact(jugador):
	if jugador.has_key(required_key):  # Verifica si el jugador tiene la llave
		if interactable:
			interactable = false
			opened = !opened  # Cambia el estado de la puerta
			if opened:
				$AnimationPlayer.play("Abrir")  # Reproduce la animación de abrir
			else:
				$AnimationPlayer.play("Cerrar")  # Reproduce la animación de cerrar
			await get_tree().create_timer(0.6, false).timeout  # Espera la duración de la animación
			interactable = true  # Permite volver a interactuar
	else:
		print("No tienes la llave para abrir esta puerta.")
