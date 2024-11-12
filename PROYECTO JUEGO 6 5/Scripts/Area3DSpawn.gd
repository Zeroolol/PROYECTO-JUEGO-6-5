extends Area3D

@onready var enemy = $"../Monster"  # Ajusta la ruta al nodo del enemigo en tu escena

func _ready():
	# Conecta la señal para detectar cuando el jugador ingresa al área
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		activate_enemy()

func activate_enemy():
	# Activa al enemigo: lo hace visible y habilita su procesamiento
	enemy.visible = true
	enemy.set_physics_process(true)  # Activa el procesamiento físico del enemigo
	enemy.set_process(true)  # Activa el procesamiento general si es necesario
	print("¡Enemigo activado!")
