extends Area3D

@onready var animation = $"EscenaFinal/AnimationPlayer"
@onready var cinematic_camera = $"EscenaFinal/Camera3D"
@onready var player_camera = $"../Player/CharacterBody3D/Cabeza/Camera3D"  # Cámara del jugador
@onready var player = get_node("../Player/CharacterBody3D")  # Nodo principal del jugador (ajusta la ruta si es necesario)

func _ready():
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		# Cambiar a la cámara de cinemática
		if cinematic_camera:
			cinematic_camera.current = true
			player_camera.current = false  # Desactiva la cámara del jugador

		# Desactivar movimiento y hacer al jugador invisible
		if player:
			player.set_process(false)  # Detiene el procesamiento (movimiento) del jugador
			player.visible = false  # Hace al jugador invisible

		# Reproducir la animación
		animation.play("AnimacionFinal")
		animation.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name):
	# Restaurar cámara y control del jugador
	if player:
		player.set_process(true)  # Reactiva el procesamiento del jugador
		player.visible = true  # Hace al jugador visible nuevamente
		player_camera.current = true
		cinematic_camera.current = false

	# Cambiar de escena al menú o cualquier otra acción final
	get_tree().change_scene_to_file("res://Escenas/menu.tscn")
