extends CharacterBody3D

var SPEED = 4
var JumpscareTime = 2
var player
var caught = false
var distance: float
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var scene_name: String
@export var patrol_points: Array[Node3D]
var chasing_player = false

# Variables de patrullaje
var patrol_target: Node3D = null
func _ready() -> void:
	player = get_node("/root/" + get_tree().current_scene.name + "/Player/CharacterBody3D")
	if player == null:
		print("Player no encontrado en la escena.")
	if patrol_points.size() == 0:
		print("Advertencia: No hay puntos de patrullaje asignados al enemigo.")
	
	# Establecer un punto de patrullaje aleatorio inicial
	set_random_patrol_target()

func _physics_process(delta):
	if visible and player and not caught:
		if not is_on_floor():
			velocity.y -= gravity * delta  # Aplicar gravedad solo si no está en el suelo
		else:
			velocity.y = 0  # Restablecer la velocidad vertical al estar en el suelo

		var current_location = global_transform.origin
		var next_location = $NavigationAgent3D.get_next_path_position()

		# Detecta la distancia al jugador
		distance = player.global_transform.origin.distance_to(current_location)
		
		if distance <= 15:
			chasing_player = true
			$NavigationAgent3D.target_position = player.global_transform.origin
		else:
			chasing_player = false
			# Si el jugador no está dentro del rango, patrulla entre los puntos
			if patrol_target:
				$NavigationAgent3D.target_position = patrol_target.global_transform.origin

				# Si está cerca del punto de patrullaje, selecciona otro punto aleatorio
				if current_location.distance_to(patrol_target.global_transform.origin) < 2:
					set_random_patrol_target()

		# Mueve al enemigo hacia la siguiente posición
		if next_location != Vector3.ZERO:
			var new_velocity = (next_location - current_location).normalized() * SPEED
			velocity.x = new_velocity.x
			velocity.z = new_velocity.z

			if chasing_player:
				look_at(player.global_transform.origin, Vector3.UP)

		# Usa move_and_slide() para mover al enemigo
		move_and_slide()

		# Verifica si está lo suficientemente cerca para "atrapar" al jugador
		if distance <= 2 and not caught:
			trigger_jumpscare()

func set_random_patrol_target():
	if patrol_points.size() > 0:
		patrol_target = patrol_points[randi() % patrol_points.size()]
		print("Nuevo punto de patrullaje: ", patrol_target.name)

func trigger_jumpscare():
	player.visible = false
	caught = true
	SPEED = 0
	velocity = Vector3.ZERO
	$JumpscareCamara.current = true
	await get_tree().create_timer(JumpscareTime, false).timeout
	get_tree().change_scene_to_file("res://Escenas/" + scene_name + ".tscn")
