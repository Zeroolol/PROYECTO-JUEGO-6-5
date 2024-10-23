extends Control  # Asegúrate de que esta clase extienda Control o la clase adecuada

@onready var label = $VBoxContainer/MarginContainer/Label  # Asegúrate de que esta ruta sea correcta

const PASSWORD = "7092"  # Código correcto
var puerta_ref  # Referencia a la puerta
var previous_mouse_mode  # Almacena el estado anterior del mouse

func show_keypad(jugador, puerta):
	self.visible = true  # Asegúrate de que el keypad se muestre
	label.text = ""  # Reiniciar el texto del label al mostrar el keypad
	puerta_ref = puerta  # Guardar referencia a la puerta
	
	# Almacena el estado actual del mouse
	previous_mouse_mode = Input.mouse_mode
	
	# Habilitar el cursor del mouse y restringirlo a la ventana del juego
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE  # Mostrar el cursor

func hide_keypad():
	self.visible = false  # Ocultar el keypad

	# Restablecer el modo del mouse al estado anterior
	Input.mouse_mode = previous_mouse_mode

func key_press(digit):
	if len(label.text) < 4:  # Permitir solo 4 dígitos
		label.text += str(digit)

func _on_button_pressed():
	key_press(1)

func _on_button_2_pressed() -> void:
	key_press(2)

func _on_button_3_pressed() -> void:
	key_press(3)

func _on_button_4_pressed() -> void:
	key_press(4)

func _on_button_5_pressed() -> void:
	key_press(5)

func _on_button_6_pressed() -> void:
	key_press(6)

func _on_button_7_pressed() -> void:
	key_press(7)

func _on_button_8_pressed() -> void:
	key_press(8)

func _on_button_9_pressed() -> void:
	key_press(9)

func _on_button_10_pressed():  # Botón "Cancelar" o "Salir"
	hide_keypad()  # Cierra el keypad cuando se presiona este botón

func _on_button_11_pressed() -> void:
	key_press(0)

func _on_button_12_pressed():  # Botón "OK"
	if label.text == PASSWORD:
		print("CORRECT PASSWORD")
		puerta_ref.interact()  # Llama a la función de la puerta para abrirla
		hide_keypad()  # Cierra el keypad después de ingresar el código
	else:
		print("WRONG PASSWORD")
