extends StaticBody3D

var interactable = true
var opened = false
var key_item_name = "LlaveTest"  # Nombre de la llave requerida
@export var required_key: String = "LlaveTest"  # Nombre de la llave requerida
@onready var dialog_label: Label = get_node("/root/TestingWorld/Dialogos/Panel/TextoDialogo")
@onready var player_camera: Camera3D = get_node("/root/TestingWorld/Player/Camera3D")  # Cámara del jugador
@onready var cinematic_camera: Camera3D = get_node("/root/TestingWorld/EscenaFinal/Camera3D")  # Cámara de la animación

func interact(jugador):
	if jugador.has_key(required_key):  # Verifica si el jugador tiene la llave
		if interactable:
			interactable = false
			opened = !opened  # Cambia el estado de la puerta
			if opened:
				# Reproduce la animación de abrir y cambia la cámara a la cámara de la animación
				$AnimationPlayer.play("Abrir")
				switch_to_cinematic_camera()
			else:
				# Reproduce la animación de cerrar y cambia la cámara a la cámara del jugador
				$AnimationPlayer.play("Cerrar")
				restore_player_camera()
			await get_tree().create_timer(0.6, false).timeout  # Espera la duración de la animación
			interactable = true  # Permite volver a interactuar
	else:
		print("No tienes la llave para abrir esta puerta.")
		mostrar_dialogo("Necesito la llave del sum para abrir la puerta")
		await get_tree().create_timer(3.0).timeout
		ocultar_dialogo()
		
func mostrar_dialogo(texto: String):
	if dialog_label:
		dialog_label.text = texto  # Cambia el texto del Label para mostrar el diálogo
		dialog_label.get_parent().visible = true  # Asegúrate de que el panel esté visible

		
func ocultar_dialogo():
	if dialog_label:
		dialog_label.get_parent().visible = false  # Oculta el panel de diálogo
		dialog_label.text = ""  # Limpia el texto del diálogo

# Función para cambiar la cámara a la cámara de la animación
func switch_to_cinematic_camera():
	if cinematic_camera:
		player_camera.current = false  # Desactiva la cámara del jugador
		cinematic_camera.current = true  # Activa la cámara de la animación

# Función para restaurar la cámara del jugador
func restore_player_camera():
	if player_camera:
		player_camera.current = true  # Reactiva la cámara del jugador
		if cinematic_camera:
			cinematic_camera.current = false  # Desactiva la cámara de la animación
