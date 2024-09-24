extends Control

@onready var mission_label: Label = $TextoObjetivos # Referencia al nodo de texto
var current_mission = ""

# Función para actualizar la misión
func update_mission(new_mission: String) -> void:
	current_mission = new_mission
	mission_label.text = current_mission
	mission_label.visible = true

	# Ocultar la misión después de 5 segundos
	await get_tree().create_timer(5.0).timeout
	mission_label.visible = false
