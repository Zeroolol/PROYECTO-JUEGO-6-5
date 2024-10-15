extends Control

var template_inv_slot = preload("res://Templates/inventoryslots.tscn")
@onready var gridcontainer = get_node("Background/MarginContainer/VBoxContainer/ScrollContainer/GridContainer")
@onready var inventory_container = $Background

var inventory: Dictionary = {}  # Asegúrate de definir el tipo de diccionario

func _ready():
	inventory_container.visible = false  # Oculta el inventario al inicio

# Función para recoger un objeto
func add_item(item_data: ItemResource):  # Sin comillas
	if item_data:
		if not inventory.has(item_data.item_name):
			inventory[item_data.item_name] = item_data
			update_inventory_ui()
		else:
			inventory[item_data.item_name].quantity += item_data.quantity  # Incrementa la cantidad si ya existe

# Actualiza la interfaz del inventario
func update_inventory_ui():
	# Limpia la UI actual
	for child in gridcontainer.get_children():
		child.queue_free()
	
	# Crea un nuevo slot para cada objeto en el inventario
	for item_name in inventory.keys():
		var item = inventory[item_name]
		var slot = template_inv_slot.instantiate()
		slot.set_item(item)  # Método que debes implementar en el slot para mostrar el item
		gridcontainer.add_child(slot)

# Maneja la entrada del jugador
func _input(event):
	if event.is_action_pressed("Inventario"):
		inventory_container.visible = not inventory_container.visible
