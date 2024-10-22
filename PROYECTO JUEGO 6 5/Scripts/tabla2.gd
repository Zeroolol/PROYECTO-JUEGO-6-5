extends StaticBody3D

@export var required_item: String = "Palanca"  # El nombre del ítem requerido (palanca)
@onready var dialog_node: Label = get_node("/root/TestingWorld/Dialogos/Panel/TextoDialogo")  # Nodo del diálogo
@onready var panel_dialogo: Panel = get_node("/root/TestingWorld/Dialogos/Panel")  # El Panel del diálogo

# Función para interactuar con las tablas
func interact(jugador):
	if jugador.is_item_selected(required_item):  # Verifica si el jugador tiene el ítem seleccionado
		remove_planks()  # Si tiene la palanca, quita las tablas
	else:
		interactuar_con_tablas()  # Si no tiene la palanca, interactúa mostrando el diálogo

# Función para remover las tablas
func remove_planks():
	print("Removiendo tablas de madera.")
	queue_free()  # Esto eliminará las tablas de la escena

# Función que maneja la interacción cuando no tiene la palanca
func interactuar_con_tablas():
	if not dialog_node or not panel_dialogo:  # Asegúrate de que los nodos de diálogo estén cargados
		print("Advertencia: Nodo de diálogo no encontrado.")
		return

	await show_dialog("Necesito una palanca.")  # Muestra el diálogo cuando el ítem no está seleccionado

# Función para mostrar el diálogo
func show_dialog(text: String) -> void:
	print("Mostrando diálogo: ", text)  # Depuración para verificar si se llama la función
	panel_dialogo.visible = true  # Hacer visible el panel de diálogo
	dialog_node.text = text  # Cambia el texto del diálogo
	await get_tree().create_timer(3.0).timeout  # Espera 3 segundos
	panel_dialogo.visible = false  # Oculta el diálogo después de un tiempo
