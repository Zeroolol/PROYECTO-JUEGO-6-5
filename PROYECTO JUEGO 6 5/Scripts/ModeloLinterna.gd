extends MeshInstance3D

var flashlight

func _ready():
	flashlight = get_node("/root/" + get_tree().current.scene.name + "/Player/Cabeza")
