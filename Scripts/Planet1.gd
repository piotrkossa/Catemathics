extends Node2D

@onready var player = get_node("Map/Player")
@onready var ui = get_node("Ui")
@onready var fight_handler = get_node("Fighting")
@onready var music_trans = $music_trans
@onready var background_music = $background

func dialog_wait(text, champ):
	ui.show_dialog.emit(text, champ)
	await ui.dialog_finished

func _ready():
	player.interaction.connect(_on_interaction)
	music_trans.play("intro")
	background_music.playing = true
	var camera = player.get_node("camera")
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 3100
	camera.limit_bottom = 3161


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
	fight_handler.start_battle.emit()
	await fight_handler.end_battle
	if global.is_alive:
		enemy.visible = false
		enemy.process_mode = Node.PROCESS_MODE_DISABLED
		player.process_mode = Node.PROCESS_MODE_INHERIT
		music_trans.play("intro")
		background_music.playing = true
		return true
	else:
		global.is_alive = true
		ui.deadscreen.emit()
		await ui.deadscreen_exited
		music_trans.play("intro")
		background_music.playing = true
		player.process_mode = Node.PROCESS_MODE_INHERIT
		return false


func _on_interaction(namee):
	if Input.is_action_just_pressed("interaction"):
		match namee:
			"Enemy1":
				await dialog_wait("Hej, chciałbym tędy przejść.", "Cat")
				await dialog_wait("පාරිභෝගිකයා ඉතා වැදගත් ය, පාරිභෝගිකයා පාරිභෝගිකයා.", "Enemy")
				await fight_enemy($Map/Enemy1)
			"Enemy2":
				await dialog_wait("Nie chcę z tobą walczyć, po prostu pozwól mi przejść...", "Cat")
				await dialog_wait("භෝගික ගිකයාඉතා වැදයාත් දයාත් පාරිභෝ ගිකයාඉ.", "Enemy")
				await fight_enemy($Map/Enemy2)
			"Enemy3":
				await dialog_wait("Ratunku! Na pomoc!", "Rune")
				await dialog_wait("Hej, zostaw go!", "Cat")
				await dialog_wait("පාරිභෝගිකයා භෝගිකගත්, පාරිවැභෝකයා ගිකයා.", "Enemy")
				var fight_result = await fight_enemy($Map/Enemy3)
				if fight_result:
					$Map/Rune.rotation = 0
					await dialog_wait("Dziękuje ci za pomoc, sam bym sobie z nim nie poradził.", "Rune")
					await dialog_wait("Jesteś niebieski jak ja! Jak się nazywasz?", "Rune")
					await dialog_wait("Nazywam się 35.", "Cat")
					await dialog_wait("35? Egzotyczne imię... Co cię tu sprowadza?", "Rune")
					await dialog_wait("Jestem członkiem kosmicznej gwardii. Przybyłem w celu uratowania tej galaktyki.", "Cat")
					await dialog_wait("Dlaczego te stwory Cię zaatakowały?", "Cat")
					await dialog_wait("To są kosmiczni piraci z innego wymiaru.", "Rune")
					await dialog_wait("Jeden z nich prześlizgnął się do naszej galaktyki i ukradł źródło zasilania magicznej bariery.", "Rune")
					await dialog_wait("Bez tej bariery nie jesteśmy w stanie powstrzymać ich przed dostaniem się tutaj.", "Rune")
					await dialog_wait("Jak przywrócić barierę?", "Cat")
					await dialog_wait("Punkt zasilający znajduje się we wnętrzu tutejszej gwiazdy.", "Rune")
					await dialog_wait("Musisz odłożyć artefakt zasilający na miejsce.", "Rune")
					await dialog_wait("Czy wiesz gdzie znajduje się ten artefakt?", "Cat")
					await dialog_wait("Chyba ma go stwór w tamtej altance.", "Rune")
			"Enemy4":
				await dialog_wait("Muszę zdobyć ten artefakt.", "Cat")
				await fight_enemy($Map/Enemy4)
			"Rune":
				await dialog_wait("Hejka, co tam? Zdobyłeś artefakt?", "Rune")
			"doors":
				if global.artifact:
					player.stop_process.emit()
					TM.transition.emit()
					music_trans.play("outro")
					await TM.on_half
					player.process_mode = Node.PROCESS_MODE_INHERIT
					get_tree().change_scene_to_file("res://Scenes/Spaceship.tscn")
				else:
					await dialog_wait("Chyba najpierw powinienem się tu rozejrzeć.", "Cat")
			"battery":
				await dialog_wait("Super, zdobyłem artefakt!", "Cat")
				await dialog_wait("Teraz muszę go odnieść do wnętrza gwiazdy. Pora wracać na statek.", "Cat")
				global.artifact = true
				$Map/battery.visible = false
				$Map/battery.process_mode = Node.PROCESS_MODE_DISABLED
