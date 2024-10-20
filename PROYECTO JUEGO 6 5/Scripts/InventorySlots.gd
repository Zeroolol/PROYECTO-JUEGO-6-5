extends TextureRect  # Assuming each slot is a TextureRect node

var item_data: ItemResource

# Function to set the item in the slot
func set_item(item: ItemResource):
	item_data = item
	# Assuming there is a TextureRect for the icon in the slot
	var icon = $Icono  # Ensure the child is called 'Icono'
	if icon and item_data.texture:
		icon.texture = item_data.texture
	else:
		print("Error: No icon found or item data has no texture.")

# Function to get the name of the item in the slot
func get_item_name() -> String:
	if item_data:
		return item_data.item_name
	return ""
