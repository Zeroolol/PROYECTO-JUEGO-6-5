extends StaticBody3D

var interactable = true
var opened = false
@onready var dialog_control: Node = get_node("/root/TestingWorld/Dialogos")  # Asegúrate de que esta ruta sea correcta

func interact(jugador):
	if interactable:
		interactable = false
		opened = !opened
		if opened:
			$AnimationPlayer.play("Abrir")
			dialog_control.iniciar_dialogo()  # Iniciar diálogos al abrir la puerta
		else:
			$AnimationPlayer.play("Cerrar")
		await get_tree().create_timer(0.6).timeout
		interactable = true
