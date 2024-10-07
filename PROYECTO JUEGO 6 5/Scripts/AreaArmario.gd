extends Area3D

@export var door_opened = false
@export var is_player_inside = false

@onready var door = $Puertas
@onready var interact_message = $InteractMessage

func _ready():
	# Desactivar el área de interacción al iniciar
	monitoring = false

func _on_body_entered(body):
	if body.name == "Player":
		monitoring = true
		is_player_inside = true
		interact_message.show()

func _on_body_exited(body):
	if body.name == "Player":
		monitoring = false
		is_player_inside = false
		interact_message.hide()

func interact():
	if is_player_inside and door_opened:
		# Ocultar al jugador
		get_node("/root/Player").hide_in_armario()
	elif is_player_inside and not door_opened:
		# Mostrar un mensaje de que la puerta está cerrada
		interact_message.text = "La puerta está cerrada"
