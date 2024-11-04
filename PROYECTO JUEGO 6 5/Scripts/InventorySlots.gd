extends TextureRect

var item_data: ItemResource

func set_item(item: ItemResource):
	item_data = item
	var icon = $Icono
	if icon and item_data.texture:
		icon.texture = item_data.texture
	var name_label = $Label  # Cambia 'Label' al nombre del nodo correcto
	if name_label:
		name_label.text = item_data.item_name

func get_item_name() -> String:
	if item_data:
		return item_data.item_name
	return ""
