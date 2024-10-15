extends Control

@onready var mission_label = $MissionLabel 

func update_mission(text: String):
	if mission_label:
		mission_label.text = text
		mission_label.visible = text != ""
