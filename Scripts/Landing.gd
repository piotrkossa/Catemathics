extends Node2D


func _on_cutscene_finished(_anim_name):
	TM.white_transition.emit()
	await TM.on_half
	get_tree().change_scene_to_file("res://Scenes/Spaceship.tscn")
