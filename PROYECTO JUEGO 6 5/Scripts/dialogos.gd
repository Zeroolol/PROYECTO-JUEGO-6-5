extends Control

@onready var dialog_label: Label = $Panel/TextoDialogo  # Obtener referencia al Label
@onready var panel_dialogo: Panel = $Panel  # Obtener referencia al Panel

# Función para mostrar el diálogo
func mostrar_dialogo(texto: String):
	panel_dialogo.visible = true  # Hacer visible el panel
	dialog_label.text = texto  # Cambia el texto del Label para mostrar el diálogo

# Función para ocultar el diálogo
func ocultar_dialogo():
	panel_dialogo.visible = false  # Hacer invisible el panel
	dialog_label.text = ""  # Limpia el texto del diálogo
