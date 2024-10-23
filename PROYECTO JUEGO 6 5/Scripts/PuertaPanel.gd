extends StaticBody3D

var interactable = true
var opened = false

func interact(jugador):
	# Verifica si la puerta es interactuable
	if interactable:
		# Evita múltiples interacciones mientras la puerta se abre o cierra
		interactable = false
		
		# Alterna el estado de la puerta (abierta/cerrada)
		opened = !opened
		
		# Ejecuta la animación adecuada
		if opened:
			$AnimationPlayer.play("Abrir")  # Si la puerta está abierta, reproduce la animación de abrir
		else:
			$AnimationPlayer.play("Cerrar")  # Si la puerta está cerrada, reproduce la animación de cerrar

		# Espera a que la animación termine antes de permitir otra interacción
		await get_tree().create_timer(0.8).timeout
		
		# Habilita la interacción nuevamente
		interactable = true
