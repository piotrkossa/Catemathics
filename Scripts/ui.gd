extends Control

signal show_dialog(text, champ, speed)
signal show_choice(text)
signal wait_for_choice()
signal deadscreen
signal deadscreen_exited

@onready var InteractionPrompt = $CanvasLayer/InteractionPrompt

@onready var Dialog = $CanvasLayer/Dialog
@onready var DialogText = Dialog.get_node("Text")
@onready var AnimPlayer = $CanvasLayer/AnimationPlayer

#######################################################
@onready var Profiles = {
	"Cat": $CanvasLayer/Dialog/Profiles/Cat,
	"LandingTable": $CanvasLayer/Dialog/Profiles/LandingTable,
	"InfoTable": $CanvasLayer/Dialog/Profiles/InfoTable,
	"MusicTable": $CanvasLayer/Dialog/Profiles/MusicTable,
	"FreezingTable": $CanvasLayer/Dialog/Profiles/FreezingTable,
	"Radio": $CanvasLayer/Dialog/Profiles/Radio,
	"Enemy": $CanvasLayer/Dialog/Profiles/Enemy,
	"Rune": $CanvasLayer/Dialog/Profiles/Rune,
	"Chef": $CanvasLayer/Dialog/Profiles/Chef
}
#######################################################
var is_interacting = false
var profile = ""

@onready var ChoicePrompt = $CanvasLayer2/ChoicePrompt
@onready var ChoiceText = $CanvasLayer2/ChoicePrompt/VBoxContainer/prompt/Text
@onready var YesChoice = $CanvasLayer2/ChoicePrompt/VBoxContainer/HBoxContainer/yes/cursor
@onready var NoChoice = $CanvasLayer2/ChoicePrompt/VBoxContainer/HBoxContainer/no/cursor
signal finished
signal dialog_finished
var is_choosing = false
var current_choice = 0
var current_dialog = 1
var dialogs_queue = 0

@onready var DeadScreenNode = $CanvasLayer/DeadScreen
var is_deadscreen = false

@onready var level = get_parent()
@onready var player = get_parent().get_node("Map/Player")

var is_menuing = false

@onready var music_trans = $music_trans
@onready var dead_music = $background
@onready var Sounds = {
	move = $menu_navigate,
	confirm = $menu_accept,
	dialog = $menu_dialog
}
func move_sound():
	Sounds.move.playing = false
	Sounds.move.playing = true

func confirm_sound():
	Sounds.confirm.playing = false
	Sounds.confirm.playing = true

func dialog_sound():
	Sounds.dialog.playing = false
	Sounds.dialog.playing = true

func _ready():
	player.interaction_prompt.connect(_on_interaction_prompt)
	show_dialog.connect(_on_show_dialog)
	show_choice.connect(_on_show_choice)
	deadscreen.connect(_on_dead)

func _on_dead():
	is_deadscreen = true
	music_trans.play("intro")
	dead_music.playing = true
	AnimPlayer.play("dead")
	DeadScreenNode.visible = true
	await AnimPlayer.animation_finished

func _on_interaction_prompt(is_active):
	if is_active:
		InteractionPrompt.visible = true
	else:
		InteractionPrompt.visible = false


func _on_show_dialog(text, champ, speed = 1.0/(len(text)/25.0)):
	dialogs_queue += 1
	var dialog_index = dialogs_queue
	while current_dialog != dialog_index:
		await dialog_finished
	is_interacting = true
	player.stop_process.emit()
	profile = Profiles[champ]
	profile.visible = true
	DialogText.text = text
	dialog_sound()
	Dialog.visible = true
	AnimPlayer.speed_scale = speed
	AnimPlayer.play("show_text")
	

func _on_show_choice(text, choice):
	dialog_sound()
	is_choosing = true
	var processmode = player.process_mode
	player.stop_process.emit()
	ChoiceText.text = text
	YesChoice.visible = true
	NoChoice.visible = false
	ChoicePrompt.visible = true
	current_choice = 0
	await finished
	ChoicePrompt.visible = false
	choice.count -= current_choice
	player.process_mode = processmode
	wait_for_choice.emit()


func _unhandled_key_input(_event):
	if (is_interacting or is_choosing or is_deadscreen) and Input.is_action_just_pressed("enter"):
		confirm_sound()
		if is_choosing:
			finished.emit()
			is_choosing = false
		elif is_interacting:
			is_interacting = false
			AnimPlayer.stop()
			Dialog.visible = false
			profile.visible = false
			player.process_mode = Node.PROCESS_MODE_INHERIT
			current_dialog += 1
			dialog_finished.emit()
		else:
			TM.transition.emit()
			music_trans.play("outro")
			await TM.on_half
			dead_music.playing = false
			DeadScreenNode.visible = false
			is_deadscreen = false
			deadscreen_exited.emit()
	elif is_choosing and Input.is_action_just_pressed("right"):
		if current_choice == 0:
			move_sound()
			current_choice = 1
			YesChoice.visible = false
			NoChoice.visible = true
	elif is_choosing and Input.is_action_just_pressed("left"):
		if current_choice == 1:
			move_sound()
			current_choice = 0
			YesChoice.visible = true
			NoChoice.visible = false
	elif Input.is_action_just_pressed("esc"):
		confirm_sound()
		if not is_menuing:
			is_menuing = true
			var pm = level.process_mode
			level.process_mode = Node.PROCESS_MODE_DISABLED
			var res = {}
			res.count = 1
			_on_show_choice("Czy na pewno chcesz wyjść do głównego menu?", res)
			await finished
			level.process_mode = pm
			is_menuing = false
			if res.count:
				get_tree().change_scene_to_file("res://Scenes/MainScreen.tscn")
	elif Input.is_action_just_pressed("devmode"):
		global.dev_mode = !global.dev_mode
		player.emit_signal("devmode_changed")

