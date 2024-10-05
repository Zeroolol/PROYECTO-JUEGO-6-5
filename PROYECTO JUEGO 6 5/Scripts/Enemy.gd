extends CharacterBody3D

# Estados del enemigo
enum EnemyState {WANDER, CHASE, SEARCH}
var current_state: EnemyState = EnemyState.WANDER

@export var patrol_speed: float = 15
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

# Agente de navegación para evitar obstáculos
var navigation_agent: NavigationAgent3D

func _ready():
	# Inicializar el NavigationAgent3D
	navigation_agent = $NavigationAgent3D

	# Asegurarse de que patrol_points_parent tiene nodos hijos
	if patrol_points_parent:
		patrol_points = patrol_points_parent.get_children().filter(func(child):
			return child is Marker3D
		)

		# Si hay puntos de patrullaje, establecer el primer objetivo
		if patrol_points.size() > 0:
			patrol_target = get_next_patrol_point()
			navigation_agent.target_location = patrol_target  # Establecer el destino en el agente

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
	navigation_agent.target_location = patrol_target  # Actualiza el destino del agente

func wander(delta):
	if is_at_patrol_point():
		patrol_target = get_next_patrol_point()  # Seleccionar un nuevo objetivo al llegar a uno
		navigation_agent.target_location = patrol_target  # Actualiza el destino del agente
	move_with_navigation(delta, patrol_speed)

func chase_player(delta):
	if player:
		var player_pos = player.global_transform.origin
		navigation_agent.target_location = player_pos  # Establecer el destino como el jugador
		move_with_navigation(delta, chase_speed)
		if is_in_jumpscare_range():
			kill_player()

func search_for_player(delta):
	search_timer -= delta
	if search_timer <= 0:
		start_wandering()

# Movimiento con navegación
# Movimiento con navegación
func move_with_navigation(delta, speed: float):
	if navigation_agent.is_navigation_finished() == false:
		var direction = navigation_agent.get_next_path_position() - global_transform.origin
		direction = direction.normalized()
		
		# Girar el enemigo hacia la dirección de movimiento
		rotate_towards_direction(direction, delta)
		
		# Calcular la velocidad
		velocity = direction * speed
		move_and_slide()  # Mueve al enemigo usando la ruta calculada por el agente

# Función para girar suavemente hacia la dirección de movimiento
func rotate_towards_direction(direction: Vector3, delta: float):
	var current_rotation = global_transform.basis.get_euler()
	var target_rotation = current_rotation

	# Obtener la rotación hacia la dirección de movimiento (en el eje Y)
	var look_at_rotation = global_transform.looking_at(global_transform.origin + direction, Vector3.UP).basis.get_euler()

	# Invertir la rotación si el enemigo está girando hacia atrás (dependiendo de la orientación del modelo)
	# Si el modelo está girando al revés, ajusta el eje Y de la rotación multiplicándolo por -1
	look_at_rotation.y += PI  # Ajusta el ángulo Y sumando 180 grados (PI radianes)

	# Interpolar suavemente la rotación en el eje Y
	target_rotation.y = lerp_angle(current_rotation.y, look_at_rotation.y, 5.0 * delta)

	# Aplicar la nueva rotación
	global_transform.basis = Basis().from_euler(target_rotation)


func get_next_patrol_point() -> Vector3:
	if patrol_points.size() > 0:
		var random_index: int
		random_index = randi() % patrol_points.size()
		while random_index == last_patrol_index:
			random_index = randi() % patrol_points.size()

		last_patrol_index = random_index
		return patrol_points[random_index].global_transform.origin
	else:
		return global_transform.origin  # Fallback

func is_at_patrol_point() -> bool:
	return global_transform.origin.distance_to(patrol_target) < PATROL_POINT_THRESHOLD

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
