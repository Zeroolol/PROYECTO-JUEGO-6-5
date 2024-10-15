extends TextureRect

@export var item_texture: Texture2D  # Usa Texture2D
@onready var icon = $Icon  # Asegúrate de que el nodo 'Icon' sea un TextureRect

func set_item(item: ItemResource):
	if icon and item.texture:
		print("Assigning texture: ", item.texture)
		icon.texture = item.texture  # Asigna la textura del ítem
		print("Texture assigned to icon: ", icon.texture)
	else:
		print("Icon or texture is not valid.")
