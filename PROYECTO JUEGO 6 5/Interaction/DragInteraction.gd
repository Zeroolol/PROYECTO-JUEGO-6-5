extends InteractionBase

class_name DragInteraction

@export var key_name: String
@export var locked_message: String
@export var open_message: String
@export var on_lock_message: String

@export var is_locked := false
@export var break_key := false

signal interaction_end

var player: Player

func _ready():
	set_process_input(false)
	set_process(false)

func stop_interaction():
	set_process(false)
	set_process_input(false)
	interaction_end.emit()

func interact(parameters=null):
	player = parameters
	var selected_item = player.get_selected_item()  # Asegúrate de tener un método para obtener el ítem seleccionado

	if selected_item:
		if selected_item.item_name == key_name:
			var message = on_lock_message
			if is_locked:
				message = open_message  # Desbloquea la puerta si está bloqueada
			if break_key:
				message += "(the key broke)"  # Si la llave se rompe, agrega el mensaje
			
			print(message)  # Muestra el mensaje al desbloquear o desbloquear

			if break_key:
				player.remove_item(key_name, 1)  # Si la llave se rompe, se elimina del inventario

			is_locked = not is_locked  # Cambia el estado de bloqueo de la puerta
		else:
			print(locked_message)  # Si la llave no es correcta, muestra el mensaje de puerta bloqueada
	elif is_locked:
		print(locked_message)  # Si la puerta está bloqueada, muestra el mensaje de puerta bloqueada

	set_process(true)
	set_process_input(true)
