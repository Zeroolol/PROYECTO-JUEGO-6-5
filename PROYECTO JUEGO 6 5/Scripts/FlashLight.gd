extends SpotLight3D

var picked_up = false  # Define la propiedad `picked_up`

func _ready():
	# Inicialización si es necesaria
	pass

func _process(delta):
	if Input.is_action_just_pressed("FlashLightEncender") and picked_up:
		visible = !visible
		$Toggle.play()
