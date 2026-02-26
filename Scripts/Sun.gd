extends Node2D

@onready var player = get_node("Map/Player")
@onready var ui = get_node("Ui")

@onready var fight_handler = $Fighting
@onready var pilar_animation = $Map/Scene2/pilaranim

@onready var music_trans = $music_trans
@onready var backgroundmusic = $background
@onready var insbackgroundmusci = $insidesun_background

var last_scene = 0

var enemydialog = false

var checked_sun = false
var placed_artifact = false

func change_music(yesorno):
	if yesorno:
		music_trans.play("outro")
		await music_trans.animation_finished
		backgroundmusic.playing = false
		music_trans.play("intro")
		insbackgroundmusci.playing = true
	else:
		music_trans.play("outro")
		await music_trans.animation_finished
		backgroundmusic.playing = true
		music_trans.play("intro")
		insbackgroundmusci.playing = false

func fight_enemy(enemy):
	if global.dev_mode:
		enemy.visible = false
		enemy.process_mode = Node.PROCESS_MODE_DISABLED
		return true
	player.stop_process.emit()
	TM.transition.emit()
	music_trans.play("outro")
	await TM.on_half
	insbackgroundmusci.playing = false
	fight_handler.start_battle.emit()
	await fight_handler.end_battle
	if global.is_alive:
		music_trans.play("intro")
		insbackgroundmusci.playing = true
		enemy.visible = false
		enemy.process_mode = Node.PROCESS_MODE_DISABLED
		player.process_mode = Node.PROCESS_MODE_INHERIT
		return true
	else:
		global.is_alive = true
		ui.deadscreen.emit()
		await ui.deadscreen_exited
		music_trans.play("intro")
		insbackgroundmusci.playing = true
		player.process_mode = Node.PROCESS_MODE_INHERIT
		return false

func scene1_init():
	TM.intro.emit()
	if last_scene == 0:
		player.position = Vector2(3575, 447)
	else:
		player.position = Vector2(1321, 601)
	last_scene = 1
	var camera = player.get_node("camera")
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 3200
	camera.limit_bottom = 960

func scene2_init():
	TM.intro.emit()
	player.position = Vector2(117, 988)
	var camera = player.get_node("camera")
	camera.limit_left = -1323
	camera.limit_top = 0
	camera.limit_right = -43
	camera.limit_bottom = 962

func _ready():
	player.interaction.connect(_on_interaction)
	scene1_init()
	music_trans.play("intro")
	backgroundmusic.playing = true

func _on_interaction(namee):
	if Input.is_action_just_pressed("interaction"):
		match namee:
			"ship_doors":
				if checked_sun or placed_artifact:
					player.stop_process.emit()
					TM.transition.emit()
					music_trans.play("outro")
					await TM.on_half
					player.process_mode = Node.PROCESS_MODE_INHERIT
					get_tree().change_scene_to_file("res://Scenes/Spaceship.tscn")
				else:
					ui.show_dialog.emit("Jeszcze się tu nie rozejrzałem.", "Cat")
			"sun_doors":
				if global.gloves:
					scene2_init()
					change_music(true)
				else:
					global.checkedsun = true
					checked_sun = true
					ui.show_dialog.emit("Ałć, te drzwi są zbyt gorące, nie otworzę ich bez rękawiczek.", "Cat")
					ui.show_dialog.emit("Chyba wiem gdzie się udać, pora wracać na statek.", "Cat")
			"enemy1":
				if not enemydialog:
					ui.show_dialog.emit("Muszę ich pokonać jeśli chcę odłożyć artefakt.", "Cat")
					await ui.dialog_finished
					enemydialog = true
				await fight_enemy($Map/Scene2/enemy1)
			"enemy2":
				if not enemydialog:
					ui.show_dialog.emit("Muszę ich pokonać jeśli chcę odłożyć artefakt.", "Cat")
					await ui.dialog_finished
					enemydialog = true
				await fight_enemy($Map/Scene2/enemy2)
			"Pilar":
				if not placed_artifact:
					ui.show_dialog.emit("Pora odłożyć artefakt na miejsce.", "Cat")
					await ui.dialog_finished
					$Map/Scene2/Pilar/artifact.visible = true
					placed_artifact = true
					global.barrier = true
					player.stop_process.emit()
					pilar_animation.play("pilar")
					await get_tree().create_timer(2).timeout 
					player.process_mode = PROCESS_MODE_INHERIT
					ui.show_dialog.emit("To zadziałało.", "Cat")
					await ui.dialog_finished
				ui.show_dialog.emit("Artefakt leży na miejscu.", "Cat")
				ui.show_dialog.emit("Pora wracać na statek.", "Cat")
	if namee == "scene1_doors":
		scene1_init()
		change_music(false)
