extends StaticBody3D

var interactable =  true
var opened = false

func interact(jugador):
	if interactable == true:
		interactable == false
		opened = !opened
		if opened == false:
			$AnimationPlayer.play("Cerrar")
		if opened == true:
			$AnimationPlayer.play("Abrir")
		await get_tree().create_timer(1.8, false).timeout
		interactable = true
