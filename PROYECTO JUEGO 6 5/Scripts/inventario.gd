extends Control

var template_inv_slot = preload("res://Templates/inventoryslots.tscn")
@onready var gridcontainer = get_node("Background/MarginContainer/VBoxContainer/ScrollContainer/GridContainer")
@onready var inventory_container = $Background

var inventory: Dictionary = {}
var slots = []
var selected_index = 0

func _ready():
	inventory_container.visible = false

# Función para agregar un ítem al inventario
func add_item(item_data: ItemResource):
	if item_data:
		if not inventory.has(item_data.item_name):
			inventory[item_data.item_name] = item_data
			update_inventory_ui()
		else:
			inventory[item_data.item_name].quantity += item_data.quantity

# Actualizar la UI del inventario
func update_inventory_ui():
	# Limpiar la UI actual
	for child in gridcontainer.get_children():
		child.queue_free()

	slots.clear()

	# Crear un slot nuevo para cada objeto en el inventario
	for item_name in inventory.keys():
		var item = inventory[item_name]
		var slot = template_inv_slot.instantiate()
		slot.set_item(item)  # Asigna el ítem al slot programáticamente
		gridcontainer.add_child(slot)
		slots.append(slot)

	highlight_selected_item()

# Función para resaltar el ítem seleccionado
func highlight_selected_item():
	if slots.size() > 0:
		for i in range(slots.size()):
			var slot = slots[i]
			slot.modulate = Color(1, 1, 1)
		slots[selected_index].modulate = Color(0.8, 0.8, 1)

# Manejar la entrada del jugador
func _input(event):
	if event.is_action_pressed("Farriba"):
		selected_index = max(0, selected_index - 1)
		highlight_selected_item()
	elif event.is_action_pressed("Fabajo"):
		selected_index = min(slots.size() - 1, selected_index + 1)
		highlight_selected_item()
		# When the player presses "Aceptar"
	elif event.is_action_pressed("Aceptar"):
		var selected_item_name = slots[selected_index].get_item_name()  # Retrieve item name from the slot
		var selected_item = inventory[selected_item_name]
		print("Selected item: ", selected_item.item_name)
	if event.is_action_pressed("Inventario"):
		inventory_container.visible = not inventory_container.visible
