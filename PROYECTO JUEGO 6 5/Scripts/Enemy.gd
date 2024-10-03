extends CharacterBody3D

# Estados del enemigo
enum EnemyState {WANDER, CHASE, SEARCH}
var current_state: EnemyState = EnemyState.WANDER

@export var patrol_speed: float = 2.0
@export var chase_speed: float = 10
@export var search_time: float = 5.0  # Tiempo que busca al jugador
@export var player: CharacterBody3D

# Nodos de puntos de patrullaje
@export var patrol_points_parent: Node3D  # Nodo padre de los puntos de patrullaje

var patrol_points: Array = []
var current_patrol_index: int = 0
var patrol_target: Vector3
var search_timer: float = 0.0  # Declarar search_timer a nivel de clas

func _ready():
	# Asegurarse de que patrol_points_parent tiene nodos hijos
	if patrol_points_parent:
		# Obtener solo los nodos Marker3D
		patrol_points = patrol_points_parent.get_children().filter(func(child):
			return child is Marker3D
		)

		# Si hay puntos de patrullaje, establecer el primer objetivo
		if patrol_points.size() > 0:
			patrol_target = patrol_points[0].global_transform.origin

	# Conexiones para los detectores
	if not $JumpscareDetector.is_connected("body_entered", Callable(self, "_on_jumpscare_detector_body_entered")):
		$JumpscareDetector.connect("body_entered", Callable(self, "_on_jumpscare_detector_body_entered"))

	if not $Detector.is_connected("body_entered", Callable(self, "_on_detector_body_entered")):
		$Detector.connect("body_entered", Callable(self, "_on_detector_body_entered"))

	if not $BiggerDetector.is_connected("body_entered", Callable(self, "_on_bigger_detector_body_entered")):
		$BiggerDetector.connect("body_entered", Callable(self, "_on_bigger_detector_body_entered"))

	start_wandering()


func _process(delta):
	match current_state:
		EnemyState.WANDER:
			$JumpscareDetector.monitoring = false
			$BiggerDetector.monitoring = true
			$Detector.monitoring = false
			wander(delta)
		EnemyState.CHASE:
			$JumpscareDetector.monitoring = true
			$BiggerDetector.monitoring = false
			$Detector.monitoring = false
			chase_player(delta)
		EnemyState.SEARCH:
			$JumpscareDetector.monitoring = false
			$BiggerDetector.monitoring = false
			$Detector.monitoring = true
			search_for_player(delta)


# Estados

func start_wandering():
	current_state = EnemyState.WANDER
	patrol_target = get_next_patrol_point()

func wander(delta):
	if is_at_patrol_point():
		patrol_target = get_next_patrol_point()
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
	var target_velocity = direction * speed
	if velocity != target_velocity:
		velocity = target_velocity
		move_and_slide()

func get_next_patrol_point() -> Vector3:
	if patrol_points.size() > 0:  # Verifica que haya puntos de patrullaje
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
		return patrol_points[current_patrol_index].global_transform.origin
	else:
		print("No hay puntos de patrullaje definidos.")
		return global_transform.origin  # Mantener la posición actual como fallback


func is_at_patrol_point() -> bool:
	return global_transform.origin.distance_to(patrol_target) < 0.5

# Jumpscare y detección

func is_in_jumpscare_range() -> bool:
	return global_transform.origin.distance_to(player.global_transform.origin) <= 2.0

func kill_player():
	get_tree().change_scene_to_file("res://Escenas/PantallaMuerte.tscn")

func player_is_running() -> bool:
	return player.velocity.length() > player.walk_speed

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
