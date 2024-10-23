# Script de la puerta (Puerta.gd)

extends StaticBody3D

@onready var animation_player = $AnimationPlayer  # Referencia al AnimationPlayer de la puerta

var interactable: bool = true  # Indica si la puerta se puede interactuar
var opened: bool = false  # Estado de la puerta

func interact():
	if interactable:
		interactable = false  # Desactivar la interacción temporalmente

		if opened:
			animation_player.play("Cerrar")
			opened = false
		else:
			animation_player.play("Abrir")
			opened = true

		# Esperar un tiempo antes de permitir la interacción de nuevo
		await get_tree().create_timer(1.8, false).timeout
		interactable = true  # Rehabilitar la interacción
