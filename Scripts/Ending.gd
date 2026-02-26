extends Node2D

@onready var music_trans = $music_trans

func _unhandled_key_input(_event):
	if Input.is_action_just_pressed("enter"):
		TM.transition.emit()
		music_trans.play("music_outro")
		await TM.on_half
		get_tree().change_scene_to_file("res://Scenes/MainScreen.tscn")
