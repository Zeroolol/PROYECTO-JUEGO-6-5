extends Control

@onready var mission_label: Label = $TextoObjetivos # Referencia al nodo de texto
@onready var instructions_label: Label = $InstruccionesLabel # Asegúrate de tener un Label para las instrucciones
var current_mission = ""

# Función para actualizar la misión
func update_mission(new_mission: String) -> void:
	current_mission = new_mission
	mission_label.text = current_mission
	mission_label.visible = true

	# Ocultar la misión después de 5 segundos
	await get_tree().create_timer(5.0).timeout
	mission_label.visible = false

# Función para mostrar instrucciones
func show_instructions(instruction_text: String) -> void:
	instructions_label.text = instruction_text
	instructions_label.visible = true

	# Ocultar las instrucciones después de 5 segundos
	await get_tree().create_timer(5.0).timeout
	instructions_label.visible = false
