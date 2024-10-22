extends StaticBody3D  # O el tipo de nodo que estés utilizando

@onready var dialog_label: Label = get_node("/root/TestingWorld/Dialogos/Panel/TextoDialogo")  # Ruta al Label de diálogo
@onready var mission_label: Label = get_node("/root/TestingWorld/Dialogos/MensajeMission")  # Ruta al Label de misión
var jugador

func _ready():
	# Imprimir los nodos para asegurarte de que no sean null
	print(dialog_label)  # Esto debería mostrar el objeto
	print(mission_label)  # Esto debería mostrar el objeto

func _input(event):
	if event.is_action_pressed("Interact"):
		if is_in_range():
			interact(jugador)  # Pasar el jugador como argumento


func is_in_range() -> bool:
	# Comprueba si el jugador está lo suficientemente cerca del objeto
	# Asumiendo que el jugador tiene un nodo llamado "Player"
	var player = get_node("/root/TestingWorld/Player")  # Cambia la ruta si es necesario
	return position.distance_to(player.position) < 2.0  # Cambia 2.0 a la distancia deseada

func interact(jugador):
	print("Interacción detectada con el jugador:", jugador)
	
	# Mostrar el diálogo
	mostrar_dialogo("lpm, se corto la luz... Tengo que buscar una forma de volver a conectarla")
	
	# Esperar un tiempo para que el diálogo se muestre
	await get_tree().create_timer(3.0).timeout
	
	# Ocultar el diálogo y mostrar el mensaje de misión
	ocultar_dialogo()
	mostrar_mision("Busca una forma de restablecer la corriente")


func mostrar_dialogo(texto: String):
	dialog_label.text = texto  # Cambia el texto del Label para mostrar el diálogo
	dialog_label.get_parent().visible = true  # Asegúrate de que el panel esté visible

func ocultar_dialogo():
	dialog_label.get_parent().visible = false  # Oculta el panel de diálogo
	dialog_label.text = ""  # Limpia el texto del diálogo

func mostrar_mision(texto: String):
	mission_label.text = texto  # Cambia el texto del Label de misión
	mission_label.get_parent().visible = true  # Asegúrate de que el Label de misión esté visible
