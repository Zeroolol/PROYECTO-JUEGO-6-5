extends CharacterBody3D

@export var navigation_region: NodePath  # Ruta al NavigationRegion3D
@export var patrol_speed: float = 4.0  # Velocidad de movimiento durante la patrulla
@export var detection_range: float = 10.0  # Rango de detección del jugador
@export var player: CharacterBody3D  # Referencia al jugador

var patrol_target: Vector3  # Posición a la que se moverá el enemigo durante la patrulla
var chasing_player = false

func _ready():
	# Obtener el nodo NavigationRegion3D
	var region = get_node(navigation_region) as NavigationRegion3D
	if region:
		patrol_target = get_random_point_in_region(region)  # Obtener un punto aleatorio para patrullar
		$NavigationAgent3D.target_position = patrol_target

func _process(delta):
	if detect_player():
		chasing_player = true
		$NavigationAgent3D.target_position = player.global_transform.origin
	else:
		chasing_player = false

	if chasing_player:
		# Perseguir al jugador
		$NavigationAgent3D.target_position = player.global_transform.origin
	else:
		# Patrullar dentro de la región
		patrol(delta)

	# Mover al enemigo hacia el objetivo usando `move_and_slide()`
	var direction = ($NavigationAgent3D.get_next_path_position() - global_transform.origin).normalized()
	velocity = direction * patrol_speed  # Establece la velocidad con base en la dirección y la velocidad de patrullaje
	move_and_slide()  # Mueve el CharacterBody3D usando la velocidad

func patrol(delta):
	# Si ha llegado al punto de patrullaje, generar un nuevo punto aleatorio dentro de la región
	if $NavigationAgent3D.is_navigation_finished():
		var region = get_node(navigation_region) as NavigationRegion3D
		patrol_target = get_random_point_in_region(region)
		$NavigationAgent3D.target_position = patrol_target

func detect_player():
	# Detectar al jugador por distancia
	var distance_to_player = global_transform.origin.distance_to(player.global_transform.origin)
	return distance_to_player <= detection_range

func get_random_point_in_region(region: NavigationRegion3D) -> Vector3:
	# Obtener el nodo CollisionShape3D o BoxShape3D asociado a la región
	var collision_shape = region.get_node("CollisionShape3D")
	
	if collision_shape:
		# Obtener el AABB del CollisionShape3D
		var shape = collision_shape.shape as BoxShape3D
		if shape:
			var aabb = shape.get_aabb()
			var center = aabb.position + aabb.size / 2
			var extents = aabb.size / 2

			# Generar un punto aleatorio dentro del AABB
			var random_point = Vector3(
				randf_range(center.x - extents.x, center.x + extents.x),
				randf_range(center.y - extents.y, center.y + extents.y),
				randf_range(center.z - extents.z, center.z + extents.z)
			)

			return random_point
		else:
			return global_transform.origin  # En caso de que no haya una BoxShape3D, retorna la posición actual
	else:
		return global_transform.origin  # En caso de que no haya CollisionShape3D, retorna la posición actual
