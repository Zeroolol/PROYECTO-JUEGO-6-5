extends CanvasLayer

func _ready():
	# Al inicio, el juego no está en pausa y el menú está oculto
	get_tree().paused = false
	$ColorRect.visible = false
	$Label.visible = false

func _physics_process(delta):
	if Input.is_action_just_pressed("Pausar"):
		# Alterna el estado de pausa y la visibilidad del menú
		get_tree().paused = not get_tree().paused
		$ColorRect.visible = not $ColorRect.visible
		$Label.visible = not $Label.visible
