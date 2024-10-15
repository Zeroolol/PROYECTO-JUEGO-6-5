extends Resource
class_name ItemResource  # Esto permite que el tipo sea reconocido globalmente

# Propiedades del item
@export var item_name: String
@export var quantity: int = 1
@export var texture: Texture2D
@export var description: String

# Puedes agregar más propiedades según sea necesario, como efectos o tipos
