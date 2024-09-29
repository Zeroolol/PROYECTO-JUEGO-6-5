extends CharacterBody3D

# Estados del enemigo
enum EnemyState {WANDER, CHASE, SEARCH}
var current_state: EnemyState = EnemyState.WANDER

@export var patrol_speed: float = 2.0
@export var chase_speed: float = 4.0
@export var search_time: float = 5.0  # Tiempo que busca al jugador
@export var player: CharacterBody3D
var search_timer: float = 0.0
var patrol_target: Vector3
var searching = false

func _ready():
	# Conectar señales de las Area3D
	$JumpscareDetector.connect("body_entered", Callable(self, "_on_jumpscare_detector_body_entered"))
	$Detector.connect("body_entered", Callable(self, "_on_detector_body_entered"))
	$BiggerDetector.connect("body_entered", Callable(self, "_on_bigger_detector_body_entered"))

	# Inicialmente, el enemigo empieza deambulando
	start_wandering()

func _physics_process(delta):
	match current_state:
		EnemyState.WANDER:
			wander(delta)
		EnemyState.CHASE:
			chase_player(delta)
		EnemyState.SEARCH:
			search_for_player(delta)


func start_wandering():
	current_state = EnemyState.WANDER
	patrol_target = get_random_patrol_point()

func wander(delta):
	# Movimiento básico de deambular (puedes expandir esto)
	move_towards(patrol_target, patrol_speed)
	if is_at_patrol_point():
		patrol_target = get_random_patrol_point()

func chase_player(delta):
	# Perseguir al jugador
	if player:
		move_towards(player.global_transform.origin, chase_speed)
		if is_in_jumpscare_range():
			kill_player()

func search_for_player(delta):
	# Buscar al jugador por un tiempo limitado
	search_timer -= delta
	if search_timer <= 0:
		start_wandering()

# Función para moverse hacia un objetivo
func move_towards(target: Vector3, speed: float):
	var direction = (target - global_transform.origin).normalized()
	velocity = direction * speed
	move_and_slide()

func is_in_jumpscare_range() -> bool:
	# Verificar si el jugador está en el rango para el jumpscare
	return global_transform.origin.distance_to(player.global_transform.origin) <= 2.0  # Cambia el rango según sea necesario

func get_random_patrol_point() -> Vector3:
	# Obtener un punto aleatorio dentro de la región de patrulla
	return Vector3(randf_range(-10, 10), 0, randf_range(-10, 10))  # Cambia según la zona de patrullaje

# Función para verificar si el enemigo está cerca del punto de patrullaje
func is_at_patrol_point() -> bool:
	# Verificar si la distancia entre el enemigo y el punto de patrullaje es pequeña (por ejemplo, 0.5 unidades)
	return global_transform.origin.distance_to(patrol_target) < 0.5

# Función para eliminar al jugador
func kill_player():
	get_tree().change_scene_to_file("res://Escenas/PantallaMuerte.tscn")

# Para verificar si el jugador está corriendo
func player_is_running() -> bool:
	# Esto dependerá de cómo implementaste el correr en el jugador.
	return player.velocity.length() > player.walk_speed

func _on_jumpscare_detector_body_entered(body: Node3D) -> void:
	if body == player:
		kill_player()

func _on_bigger_detector_body_entered(body: Node3D) -> void:
	if body == player:
		current_state = EnemyState.CHASE

func _on_detector_body_entered(body: Node3D) -> void:
	if body == player and player.is_running():  # Asume que tienes un método para verificar si el jugador corre
		current_state = EnemyState.SEARCH
		search_timer = search_time
		patrol_target = player.global_transform.origin  # Empieza a buscar donde escuchó el ruido
