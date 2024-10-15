extends Area3D

@export var jugador_scene: CharacterBody3D # Ruta al nodo del jugador

var dialogo_mostrado = false

# Conectar señal correctamente
func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

# Detecta cuando el jugador entra en la zona
func _on_body_entered(body: Node):
	if body.is_in_group("player") and not dialogo_mostrado:
		mostrar_dialogo()
		dialogo_mostrado = true

# Llama al sistema de diálogos
func mostrar_dialogo():
	var control_dialogos = get_node("/root/NombreDelNodoDialogos")
	control_dialogos.mostrar_dialogo("Este es el inicio de la misión.")
