extends Control

@onready var MainSite = $MainMenu/MainSite
@onready var OptionSite = $MainMenu/OptionSite

var isMainSite = true

@onready var MenuCursors = [$MainMenu/MainSite/Exit/cursor, $MainMenu/MainSite/Options/cursor, $MainMenu/MainSite/Start/cursor]
var MenuCursorCounter = 2

@onready var OptionCursors = [$MainMenu/OptionSite/Fullscreen/cursor, $MainMenu/OptionSite/Back/cursor]
var OptionsCursorCounter = 1

@onready var Animations = $Animations

@onready var Sounds = {
	move = $menu_navigate,
	confirm = $menu_accept
}

var interact = true

func move_sound():
	Sounds.move.playing = false
	Sounds.move.playing = true

func confirm_sound():
	Sounds.confirm.playing = false
	Sounds.confirm.playing = true

func _on_ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if global.is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN) 
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED) 
	global.is_alive = true
	global.game_stage = 0
	global.artifact = false
	global.checkedsun = false
	global.gloves = false
	global.barrier = false


func _on_returnbutton_pressed():
	MainSite.visible = true
	OptionSite.visible = false


func handle_menu_cursors():
	if Input.is_action_just_pressed("down"):
		if MenuCursorCounter > 0:
			move_sound()
			MenuCursors[MenuCursorCounter].visible = false
			MenuCursorCounter -= 1
			MenuCursors[MenuCursorCounter].visible = true
	elif Input.is_action_just_pressed("up"):
		if MenuCursorCounter < 2:
			move_sound()
			MenuCursors[MenuCursorCounter].visible = false
			MenuCursorCounter += 1
			MenuCursors[MenuCursorCounter].visible = true
	elif Input.is_action_just_pressed("enter"):
		confirm_sound()
		match MenuCursorCounter:
			0:
				get_tree().quit()
			1:
				MainSite.visible = false
				OptionSite.visible = true
				isMainSite = false
			_:
				TM.transition.emit()
				Animations.play("Transition")
				interact = false
				await TM.on_half
				get_tree().change_scene_to_file.bind("res://Scenes/Spaceship.tscn").call_deferred()
		

func handle_options_cursors():
	if Input.is_action_just_pressed("down"):
		if OptionsCursorCounter > 0:
			move_sound()
			OptionCursors[OptionsCursorCounter].visible = false
			OptionsCursorCounter -= 1
			OptionCursors[OptionsCursorCounter].visible = true
	elif Input.is_action_just_pressed("up"):
		if OptionsCursorCounter < 1:
			move_sound()
			OptionCursors[OptionsCursorCounter].visible = false
			OptionsCursorCounter += 1
			OptionCursors[OptionsCursorCounter].visible = true
	elif Input.is_action_just_pressed("enter"):
		confirm_sound()
		match OptionsCursorCounter:
			0:
				if global.is_fullscreen:
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
					$MainMenu/OptionSite/Fullscreen/Label.text = "Pełny ekran"
					global.is_fullscreen = false
				else:
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN) 
					$MainMenu/OptionSite/Fullscreen/Label.text = "Okno"
					global.is_fullscreen = true
			_:
				MainSite.visible = true
				OptionSite.visible = false
				isMainSite = true

func _process(_delta):
	if interact:
		if isMainSite:
			handle_menu_cursors()
		else:
			handle_options_cursors()
