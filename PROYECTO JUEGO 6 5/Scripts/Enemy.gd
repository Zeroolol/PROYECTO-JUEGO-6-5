extends CharacterBody3D

# Estados del enemigo
enum EnemyState {WANDER, CHASE, SEARCH}
var current_state: EnemyState = EnemyState.WANDER

@export var patrol_speed: float = 2.0
@export var chase_speed: float = 10.0
@export var search_time: float = 5.0  # Tiempo que busca al jugador
@export var player: CharacterBody3D

# Nodos de puntos de patrullaje
@export var patrol_points_parent: Node3D  # Nodo padre de los puntos de patrullaje

var patrol_points: Array = []
var last_patrol_index: int = -1  # Para recordar el último índice patrullado
var patrol_target: Vector3
var search_timer: float = 0.0  # Declarar search_timer a nivel de clase

# Umbral de proximidad para considerar que se ha alcanzado el punto de patrulla
const PATROL_POINT_THRESHOLD = 2.0

func _ready():
	# Asegurarse de que patrol_points_parent tiene nodos hijos
	if patrol_points_parent:
		# Obtener solo los nodos Marker3D
		patrol_points = patrol_points_parent.get_children().filter(func(child):
			return child is Marker3D
		)

		# Si hay puntos de patrullaje, establecer el primer objetivo
		if patrol_points.size() > 0:
			patrol_target = get_next_patrol_point()

	# Conexiones para los detectores
	$JumpscareDetector.connect("body_entered", Callable(self, "_on_jumpscare_detector_body_entered"))
	$Detector.connect("body_entered", Callable(self, "_on_detector_body_entered"))
	$BiggerDetector.connect("body_entered", Callable(self, "_on_bigger_detector_body_entered"))

	start_wandering()

func _process(delta):
	match current_state:
		EnemyState.WANDER:
			wander(delta)
		EnemyState.CHASE:
			chase_player(delta)
		EnemyState.SEARCH:
			search_for_player(delta)

# Estados

func start_wandering():
	current_state = EnemyState.WANDER
	patrol_target = get_next_patrol_point()

func wander(delta):
	if is_at_patrol_point():
		print("Reached patrol point, selecting next target.")
		patrol_target = get_next_patrol_point()  # Seleccionar un nuevo objetivo al llegar a uno
	move_towards(patrol_target, patrol_speed)

func chase_player(delta):
	if player:
		var player_pos = player.global_transform.origin
		move_towards(player_pos, chase_speed)
		if is_in_jumpscare_range():
			kill_player()

func search_for_player(delta):
	search_timer -= delta
	if search_timer <= 0:
		start_wandering()

# Movimiento y Patrullaje

func move_towards(target: Vector3, speed: float):
	var direction = (target - global_transform.origin).normalized()
	velocity = direction * speed
	move_and_slide()  # Mueve al enemigo

func get_next_patrol_point() -> Vector3:
	if patrol_points.size() > 0:  # Verifica que haya puntos de patrullaje
		var random_index: int
		# Elegir un índice aleatorio diferente al último
		random_index = randi() % patrol_points.size()
		while random_index == last_patrol_index:
			random_index = randi() % patrol_points.size()

		last_patrol_index = random_index  # Actualizar el último índice patrullado
		print("Next patrol point: ", patrol_points[random_index].global_transform.origin)
		return patrol_points[random_index].global_transform.origin
	else:
		print("No hay puntos de patrullaje definidos.")
		return global_transform.origin  # Mantener la posición actual como fallback

func is_at_patrol_point() -> bool:
	var at_point = global_transform.origin.distance_to(patrol_target) < PATROL_POINT_THRESHOLD
	print("At patrol point: ", at_point)
	return at_point

func is_in_jumpscare_range() -> bool:
	return global_transform.origin.distance_to(player.global_transform.origin) <= 2.0

func kill_player():
	get_tree().change_scene_to_file("res://Escenas/PantallaMuerte.tscn")

func player_is_running() -> bool:
	if player.has_method("get_walk_speed"):
		return player.velocity.length() > player.get_walk_speed()
	return false

# Detectores

func _on_jumpscare_detector_body_entered(body: Node3D) -> void:
	if body == player:
		kill_player()

func _on_bigger_detector_body_entered(body: Node3D) -> void:
	if body == player:
		current_state = EnemyState.CHASE

func _on_detector_body_entered(body: Node3D) -> void:
	if body == player and player_is_running():
		current_state = EnemyState.SEARCH
		search_timer = search_time
		patrol_target = player.global_transform.origin
