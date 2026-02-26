extends Node2D

@onready var player = $Map/Player
@onready var ui = $Ui
@onready var animations = $AnimationPlayer
@onready var fight_handler = $Fighting

@onready var music_trans = $music_trans
@onready var background_music = $background
@onready var bistro_music = $background_bistro

var last_scene = 0

func change_music(yesorno):
	if yesorno:
		music_trans.play("outro")
		await music_trans.animation_finished
		background_music.playing = false
		bistro_music.playing = true
		music_trans.play("intro")
	else:
		music_trans.play("outro")
		await music_trans.animation_finished
		bistro_music.playing = false
		background_music.playing = true
		music_trans.play("intro")

func scene1_init():
	if last_scene == 0:
		player.position = Vector2(820, 332)
	else:
		player.position = Vector2(61, 441)
	last_scene = 1
	TM.intro.emit()
	var camera = player.get_node("camera")
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 1280
	camera.limit_bottom = 960

func scene2_init():
	if last_scene == 1:
		player.position = Vector2(-121, 441)
	else:
		player.position = Vector2(-2573, 441)
	last_scene = 2
	TM.intro.emit()
	var camera = player.get_node("camera")
	camera.limit_left = -2628
	camera.limit_top = 0
	camera.limit_right = -68
	camera.limit_bottom = 960

func scene3_init():
	if last_scene == 2:
		player.position = Vector2(-2942, 441)
	else:
		player.position = Vector2(-6018, -542)
	last_scene = 3
	TM.intro.emit()
	var camera = player.get_node("camera")
	camera.limit_left = -6076
	camera.limit_top = -1424
	camera.limit_right = -2880
	camera.limit_bottom = 967

func scene4_init():
	if last_scene == 3:
		player.position = Vector2(-6275, -542)
	else:
		change_music(false)
		player.position = Vector2(-7280, -596)
	last_scene = 4
	TM.intro.emit()
	var camera = player.get_node("camera")
	camera.limit_left = -8319
	camera.limit_top = -1356
	camera.limit_right = -6223
	camera.limit_bottom = -80

func scene5_init():
	change_music(true)
	last_scene = 5
	player.position = Vector2(-7323, -1560)
	TM.intro.emit()
	var camera = player.get_node("camera")
	camera.limit_left = -7960
	camera.limit_top = -2435
	camera.limit_right = -6680
	camera.limit_bottom = -1475

func _ready():
	music_trans.play("intro")
	player.interaction.connect(_on_interaction)
	scene1_init()

func fight_enemy(enemy):
	if global.dev_mode:
		enemy.visible = false
		enemy.process_mode = Node.PROCESS_MODE_DISABLED
		return true
	player.stop_process.emit()
	TM.transition.emit()
	music_trans.play("outro")
	await TM.on_half
	background_music.playing = false
	bistro_music.playing = false
	fight_handler.start_battle.emit()
	await fight_handler.end_battle
	if global.is_alive:
		music_trans.play("intro")
		if last_scene == 5:
			bistro_music.playing = true
		else:
			background_music.playing = true
		enemy.visible = false
		enemy.process_mode = Node.PROCESS_MODE_DISABLED
		player.process_mode = Node.PROCESS_MODE_INHERIT
		return true
	else:
		global.is_alive = true
		ui.deadscreen.emit()
		await ui.deadscreen_exited
		player.process_mode = Node.PROCESS_MODE_INHERIT
		music_trans.play("intro")
		if last_scene == 5:
			bistro_music.playing = true
		else:
			background_music.playing = true
		return false

var chef_dialog = false
var enemy1 = false
var enemy2 = false
func _on_interaction(namee):
	if Input.is_action_just_pressed("interaction"):
		match namee:
			"spaceship_enter":
				if not global.gloves:
					ui.show_dialog.emit("Muszę się tu jeszcze rozejrzeć.", "Cat")
				else:
					player.stop_process.emit()
					music_trans.play("outro")
					TM.transition.emit()
					await TM.on_half
					player.process_mode = Node.PROCESS_MODE_INHERIT
					get_tree().change_scene_to_file("res://Scenes/Spaceship.tscn")
			"bar_doors":
				scene5_init()
			"chef":
				if not chef_dialog:
					ui.show_dialog.emit("Witaj, jestem Gabriel. W czym mogę ci pomóc?", "Chef")
					ui.show_dialog.emit("Cześć, mam nietypową prośbę. Potrzebuję rękawic do pieczenia.", "Cat")
					ui.show_dialog.emit("Hmmm, powinienem mieć jakieś zapasowe, za chwilę sprawdzę.", "Chef")
					ui.show_dialog.emit("Czy w między czasie mógłbyś zrobić coś dla mnie? Widzisz tych dwóch na lewo od lady?", "Chef")
					ui.show_dialog.emit("Stoją już tu tak cały dzień i straszą mi klientów. Pomożesz mi z tym?", "Chef")
					chef_dialog = true
				elif enemy1 and enemy2:
					if global.gloves:
						ui.show_dialog.emit("Co tam?", "Chef")
					else:
						ui.show_dialog.emit("Dzięki wielkie, dobra robota. Oto twoje rękawiczki.", "Chef")
						global.gloves = true
				else:
					ui.show_dialog.emit("Jak tam idzie z tymi dwoma?", "Chef")
			"chef_enemy1":
				if chef_dialog:
					if await fight_enemy($Map/Scene5/chef_enemy1):
						enemy1 = true
				else:
					ui.show_dialog.emit("Hej...", "Cat")
			"chef_enemy2":
				if chef_dialog:
					if await fight_enemy($Map/Scene5/chef_enemy2):
						enemy2 = true
				else:
					ui.show_dialog.emit("Hej...", "Cat")
			"Enemy1":
				await fight_enemy($Map/Scene2/Enemy1)
			"Enemy2":
				await fight_enemy($Map/Scene3/Enemy2)
			"Enemy3":
				await fight_enemy($Map/Scene3/Enemy3)
	match namee:
		"scene1_enter":
			scene1_init()
		"scene2_enter":
			scene2_init()
		"scene3_enter":
			scene3_init()
		"scene4_enter":
			scene4_init()
			
