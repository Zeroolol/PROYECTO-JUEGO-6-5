extends Area3D

@onready var enemy = $"../Monster"  # Ajusta la ruta para apuntar al enemigo

func _ready():
	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		enemy.player_entered_safe_zone()
		print("Jugador ingresó en la zona segura.")

func _on_body_exited(body):
	if body.is_in_group("player"):
		enemy.player_exited_safe_zone()
		print("Jugador salió de la zona segura.")
