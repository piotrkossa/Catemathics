extends Node2D


@onready var player = get_node("Map/Player")
@onready var ui = get_node("Ui")

@onready var animationplayer = $AnimationPlayer

@onready var stage1cabin = $Map/Cabin/cabin_frame
@onready var stage2cabin = $Map/Cabin/cabin_frame2
@onready var stage3cabin = $Map/Cabin/cabin_frame3

@onready var background_music = $background
@onready var music_trans = $music_trans
@onready var table_music = $music_table
@onready var music_table_trans = $music_table_trans

var did_check_radio = false

var input_handler

func play_music_table():
	if not table_music.playing:
		ui.show_dialog.emit("*Gra muzyka*", "MusicTable")
		table_music.playing = true
		music_table_trans.play("intro")
		await ui.dialog_finished
		music_table_trans.play("outro")
		await music_table_trans.animation_finished
		table_music.playing = false

func _on_ready():
	music_trans.play("intro")
	background_music.playing = true
	player.process_mode = Node.PROCESS_MODE_INHERIT
	player.interaction.connect(_on_interaction)
	var camera = player.get_node("camera")
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 1664
	camera.limit_bottom = 2368
	if global.game_stage == 0:
		input_handler = Callable(self, "stage0")
		stage1cabin.visible = true
		stage2cabin.visible = false
		stage3cabin.visible = false
		animationplayer.play("awaking")
		await animationplayer.animation_finished
		ui.show_dialog.emit("Brrrr", "Cat")
		ui.show_dialog.emit("Bbbbarrdzo zzzimno.", "Cat")
	elif global.game_stage == 1:
		input_handler = Callable(self, "stage1")
		if global.artifact:
			player.position = Vector2(656, 2096)
		else:
			TM.white_intro.emit()
			player.position = Vector2(672, 488)
		stage1cabin.visible = false
		stage2cabin.visible = true
		stage3cabin.visible = false
	elif global.game_stage == 2:
		input_handler = Callable(self, "stage2")
		if global.checkedsun:
			player.position = Vector2(656, 2096)
		else:
			player.position = Vector2(672, 488)
		stage1cabin.visible = false
		stage2cabin.visible = false
		stage3cabin.visible = true
	elif global.game_stage == 3:
		input_handler = Callable(self, "stage3")
		if global.gloves:
			player.position = Vector2(656, 2096)
		else:
			player.position = Vector2(672, 488)
		stage1cabin.visible = false
		stage2cabin.visible = true
		stage3cabin.visible = false
	elif global.game_stage == 4:
		input_handler = Callable(self, "stage4")
		if global.barrier:
			player.position = Vector2(656, 2096)
		else:
			player.position = Vector2(672, 488)
		stage1cabin.visible = false
		stage2cabin.visible = false
		stage3cabin.visible = true

func stage0(namee):
	match namee:
		"MusicTable":
			play_music_table()
		"InfoTable":
			ui.show_dialog.emit("Atmosfera: Próżnia\nPaliwo: 50%\nGotowość do lądowania", "InfoTable")
		"LandingTable":
			if did_check_radio:
				var result = await handle_choice_prompt("Czy na pewno chcesz rozpocząć procedurę wejścia w orbitę?")
				if result:
					ui.show_dialog.emit("Uruchamiam silniki.", "LandingTable")
					await ui.dialog_finished
					ui.show_dialog.emit("Kierunek: Planeta A-53", "LandingTable")
					await ui.dialog_finished
					player.stop_process.emit()
					TM.transition.emit()
					music_trans.play("outro")
					await TM.on_half
					background_music.playing = false
					global.game_stage = 1
					get_tree().change_scene_to_file("res://Scenes/Landing.tscn")
			else:
				ui.show_dialog.emit("Chyba najpierw powinienem sprawdzić radio.", "Cat")
		"Doors":
			ui.show_dialog.emit("Muszę kontynuować moją misję.", "Cat")
		"Freezer":
			ui.show_dialog.emit("Nie mogę się teraz zamrozić.", "Cat")
		"FreezingTable":
			ui.show_dialog.emit("Stan: Niezamrożony", "FreezingTable")
		"Radio":
			if not did_check_radio:
				ui.show_dialog.emit("Witaj 35, tu centrala. Jeśli widzisz tę wiadomość, to znaczy, że się obudziłeś.", "Radio")
				ui.show_dialog.emit("Proces zamrażania może powodować utratę pamięci, dlatego przypomnę cel twojej misji.", "Radio")
				ui.show_dialog.emit("Twoim zadaniem będzie uratowanie galaktyki NGC-35 przed zagładą.", "Radio")
				ui.show_dialog.emit("W twoich rękach są życia jej mieszkańców. Powodzenia 35!", "Radio")
				did_check_radio = true
			else:
				ui.show_dialog.emit("*Brak nowych wiadomości*", "Radio")

func stage1(namee):
	match namee:
		"MusicTable":
			play_music_table()
		"InfoTable":
			ui.show_dialog.emit("Atmosfera: Przyjazna\nPaliwo: 35%\nWylądowano", "InfoTable")
		"LandingTable":
			if global.artifact:
				var result = await handle_choice_prompt("Czy na pewno chcesz rozpocząć procedurę wejścia w orbitę?")
				if result:
					ui.show_dialog.emit("Uruchamiam silniki.", "LandingTable")
					await ui.dialog_finished
					ui.show_dialog.emit("Kierunek: Gwiazda", "LandingTable")
					await ui.dialog_finished
					player.stop_process.emit()
					TM.white_transition.emit()
					music_trans.play("outro")
					await TM.on_half
					background_music.playing = false
					global.game_stage = 2
					get_tree().change_scene_to_file("res://Scenes/Spaceship.tscn")
			else:
				ui.show_dialog.emit("Najpierw muszę się tu rozejrzeć.", "Cat")
		"Doors":
			if global.artifact:
				ui.show_dialog.emit("Muszę kontynuować moją misję.", "Cat")
			else:
				ui.show_dialog.emit("Muszę uważać, na tej planecie może być niebezpiecznie.", "Cat")
				await ui.dialog_finished
				player.stop_process.emit()
				TM.transition.emit()
				music_trans.play("outro")
				await TM.on_half
				background_music.playing = false
				player.process_mode = Node.PROCESS_MODE_INHERIT
				get_tree().change_scene_to_file("res://Scenes/Planet1.tscn")
		"Freezer":
			ui.show_dialog.emit("Nie mogę się teraz zamrozić.", "Cat")
		"FreezingTable":
			ui.show_dialog.emit("Stan: Niezamrożony", "FreezingTable")
		"Radio":
			ui.show_dialog.emit("*Brak nowych wiadomości*", "Radio")

func stage2(namee):
	match namee:
		"MusicTable":
			play_music_table()
		"InfoTable":
			ui.show_dialog.emit("Atmosfera: Próżnia\nPaliwo: 30%\nOrbitowanie", "InfoTable")
		"LandingTable":
			if global.checkedsun:
				var result = await handle_choice_prompt("Czy na pewno chcesz rozpocząć procedurę wejścia w orbitę?")
				if result:
					ui.show_dialog.emit("Uruchamiam silniki.", "LandingTable")
					await ui.dialog_finished
					ui.show_dialog.emit("Kierunek: Planeta B-13", "LandingTable")
					await ui.dialog_finished
					player.stop_process.emit()
					TM.white_transition.emit()
					music_trans.play("outro")
					await TM.on_half
					background_music.playing = false
					global.game_stage = 3
					get_tree().change_scene_to_file("res://Scenes/Spaceship.tscn")
			else:
				ui.show_dialog.emit("Najpierw muszę się tu rozejrzeć.", "Cat")
		"Doors":
			if global.checkedsun:
				ui.show_dialog.emit("Muszę kontynuować moją misję.", "Cat")
			else:
				player.stop_process.emit()
				TM.transition.emit()
				music_trans.play("outro")
				await TM.on_half
				background_music.playing = false
				player.process_mode = Node.PROCESS_MODE_INHERIT
				get_tree().change_scene_to_file("res://Scenes/Sun.tscn")
		"Freezer":
			ui.show_dialog.emit("Nie mogę się teraz zamrozić.", "Cat")
		"FreezingTable":
			ui.show_dialog.emit("Stan: Niezamrożony", "FreezingTable")
		"Radio":
			ui.show_dialog.emit("*Brak nowych wiadomości*", "Radio")

func stage3(namee):
	match namee:
		"MusicTable":
			play_music_table()
		"InfoTable":
			ui.show_dialog.emit("Atmosfera: Przyjazna\nPaliwo: 23%\nWylądowano", "InfoTable")
		"LandingTable":
			if global.gloves:
				var result = await handle_choice_prompt("Czy na pewno chcesz rozpocząć procedurę wejścia w orbitę?")
				if result:
					ui.show_dialog.emit("Uruchamiam silniki.", "LandingTable")
					await ui.dialog_finished
					ui.show_dialog.emit("Kierunek: Gwiazda", "LandingTable")
					await ui.dialog_finished
					player.stop_process.emit()
					TM.white_transition.emit()
					music_trans.play("outro")
					await TM.on_half
					background_music.playing = false
					global.game_stage = 4
					get_tree().change_scene_to_file("res://Scenes/Spaceship.tscn")
			else:
				ui.show_dialog.emit("Najpierw muszę się tu rozejrzeć.", "Cat")
		"Doors":
			if global.gloves:
				ui.show_dialog.emit("Muszę kontynuować moją misję.", "Cat")
			else:
				player.stop_process.emit()
				TM.transition.emit()
				music_trans.play("outro")
				await TM.on_half
				background_music.playing = false
				player.process_mode = Node.PROCESS_MODE_INHERIT
				get_tree().change_scene_to_file("res://Scenes/Cafe.tscn")
		"Freezer":
			ui.show_dialog.emit("Nie mogę się teraz zamrozić.", "Cat")
		"FreezingTable":
			ui.show_dialog.emit("Stan: Niezamrożony", "FreezingTable")
		"Radio":
			ui.show_dialog.emit("*Brak nowych wiadomości*", "Radio")

func stage4(namee):
	match namee:
		"MusicTable":
			play_music_table()
		"InfoTable":
			ui.show_dialog.emit("Atmosfera: Próżnia\nPaliwo: 17%\nOrbitowanie", "InfoTable")
		"LandingTable":
			if global.barrier:
				if not did_check_radio:
					ui.show_dialog.emit("Najpierw powinienem sprawdzić radio.", "Cat")
				else:
					ui.show_dialog.emit("Muszę wracać do zamrażalki.", "Cat")
			else:
				ui.show_dialog.emit("Najpierw muszę się tu rozejrzeć.", "Cat")
		"Doors":
			if global.barrier:
				ui.show_dialog.emit("Muszę kontynuować moją misję.", "Cat")
			else:
				player.stop_process.emit()
				TM.transition.emit()
				music_trans.play("outro")
				await TM.on_half
				background_music.playing = false
				player.process_mode = Node.PROCESS_MODE_INHERIT
				get_tree().change_scene_to_file("res://Scenes/Sun.tscn")
		"Freezer":
			if not did_check_radio:
				ui.show_dialog.emit("Nie mogę się teraz zamrozić.", "Cat")
			else:
				player.stop_process.emit()
				animationplayer.play("freezing")
				await animationplayer.animation_finished
				get_tree().change_scene_to_file("res://Scenes/Ending.tscn")
		"FreezingTable":
			ui.show_dialog.emit("Stan: Niezamrożony", "FreezingTable")
		"Radio":
			if not global.barrier:
				ui.show_dialog.emit("*Brak nowych wiadomości*", "Radio")
			else:
				if not did_check_radio:
					ui.show_dialog.emit("Dobra robota 35.", "Radio")
					ui.show_dialog.emit("Bariera została przywrócona, a mieszkańcy galaktyki NGC-35 są znowu bezpieczni.", "Radio")
					ui.show_dialog.emit("Pora na powrót do centrali, wróc do zamrażalki. Czekamy na Ciebie.", "Radio")
					did_check_radio = true
				else:
					ui.show_dialog.emit("*Brak nowych wiadomości*", "Radio")

func _on_interaction(namee):
	if Input.is_action_just_pressed("interaction"):
		input_handler.call(namee)

func handle_choice_prompt(text):
	var choice = {}
	choice.count = 1
	ui.show_choice.emit(text, choice)
	await ui.wait_for_choice
	return choice.count

