extends StaticBody3D  # El nodo dentro del PanelElectrico

var panel_interacted: bool = false  # Propiedad que indica si el jugador ya interactuó con el panel

@onready var dialog_label: Label = get_node("/root/TestingWorld/Dialogos/Panel/TextoDialogo")  # Ruta al Label de diálogo
@onready var mensaje_label: Label = get_node("/root/TestingWorld/Dialogos/MensajeMission")  # Ruta al Label de misión
@onready var jugador = get_node("/root/TestingWorld/Player")  # Referencia al jugador

func _input(event):
	if event.is_action_pressed("Interact"):
		if is_in_range():
			interact(jugador)

# Comprueba si el jugador está lo suficientemente cerca del objeto
func is_in_range() -> bool:
	return position.distance_to(jugador.position) < 2.0  # Cambia 2.0 a la distancia deseada

# Función para interactuar con el panel eléctrico
func interact(jugador):
	# Actualizar la propiedad panel_interacted
	panel_interacted = true
	print("Interacción con el panel realizada, panel_interacted =", panel_interacted)
	
	# Mostrar el diálogo y misión
	mostrar_dialogo("Las luces se quemaron pero tal vez haga funcionar al teléfono")
	await get_tree().create_timer(3.0).timeout
	ocultar_dialogo()
	await mostrar_mensaje_final("REGRESA A PRECEPTORÍA")

# Función para mostrar el mensaje final
func mostrar_mensaje_final(mensaje: String):
	mensaje_label.text = mensaje
	mensaje_label.visible = true
	await get_tree().create_timer(3.0).timeout
	mensaje_label.visible = false

# Función para mostrar el diálogo
func mostrar_dialogo(texto: String):
	dialog_label.text = texto
	dialog_label.get_parent().visible = true

# Función para ocultar el diálogo
func ocultar_dialogo():
	dialog_label.get_parent().visible = false
	dialog_label.text = ""
