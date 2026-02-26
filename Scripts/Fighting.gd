extends Node2D

@onready var ui = self.get_parent().get_node("Ui")
@onready var canvas = $CanvasLayer

# Animations
@onready var animationplayer = $CanvasLayer/AnimationPlayer

# Buttons
@onready var MainNode = $CanvasLayer/Main
@onready var MainButtonsNode = $CanvasLayer/Main/Buttons
@onready var MainButtons = [$CanvasLayer/Main/Buttons/Fight/cursor, $CanvasLayer/Main/Buttons/Check/cursor]

@onready var MathQuestionNode = $CanvasLayer/MathQuestion
@onready var MathQuestionText = $CanvasLayer/MathQuestion/prompt/Text
@onready var MathQuestionButtonsText = [$CanvasLayer/MathQuestion/Option1/Label, $CanvasLayer/MathQuestion/Option2/Label]
@onready var MathQuestionButtons = [$CanvasLayer/MathQuestion/Option1/cursor, $CanvasLayer/MathQuestion/Option2/cursor]

# Prompt
@onready var PromptNode = $CanvasLayer/Prompt
@onready var PromptText = $CanvasLayer/Prompt/prompt/Text

# HealthBars
var enemy_health = 5
var player_health = 5

var player_attack = 2
var enemy_attack = 1

@onready var PlayerHB = $CanvasLayer/Main/Player/health
@onready var EnemyHB = $CanvasLayer/Main/Enemy/health

@onready var Hitmaker = $CanvasLayer/Main/Hitmaker
@onready var HitmakerText = $CanvasLayer/Main/Hitmaker/Label

@onready var BackgroundMusic = $background

@onready var Sounds = {
	move = $menu_navigate,
	confirm = $menu_accept,
	dialog = $menu_dialog,
	hit = $hit,
	missed = $missed
}

func dialog_sound():
	Sounds.dialog.playing = false
	Sounds.dialog.playing = true

func move_sound():
	Sounds.move.playing = false
	Sounds.move.playing = true

func confirm_sound():
	Sounds.confirm.playing = false
	Sounds.confirm.playing = true

# Button Functions
var is_menuing = false
var is_fighting = false
var is_prompting = false

signal start_battle
signal end_battle

func _intro():
	animationplayer.stop()
	enemy_health = 5
	player_health = 5
	is_fighting = false
	is_prompting = false
	canvas.process_mode = PROCESS_MODE_INHERIT
	PlayerHB.size = Vector2(275, 15)
	EnemyHB.size = Vector2(220, 12)
	main_current_option = 0
	MainButtons[0].visible = true
	MainButtons[1].visible = false
	canvas.visible = true
	animationplayer.play("start")
	BackgroundMusic.playing = true
	MainNode.visible = true
	await animationplayer.animation_finished
	is_menuing = true
func _outro():
	BackgroundMusic.playing = false
	animationplayer.stop()
	TM.intro.emit()
	is_menuing = false
	canvas.process_mode = Node.PROCESS_MODE_DISABLED
	canvas.visible = false
	MainNode.visible = false

var main_current_option = 0
func handle_main_buttons():
	if Input.is_action_just_pressed("right"):
		if main_current_option == 0:
			move_sound()
			MainButtons[main_current_option].visible = false
			main_current_option = 1
			MainButtons[main_current_option].visible = true
	elif Input.is_action_just_pressed("left"):
		if main_current_option == 1:
			move_sound()
			MainButtons[main_current_option].visible = false
			main_current_option = 0
			MainButtons[main_current_option].visible = true
	elif Input.is_action_just_pressed("enter"):
		confirm_sound()
		is_menuing = false
		match main_current_option:
			0:
				var fight_result = await fight()
				Hitmaker.position = Vector2(695, -133)
				HitmakerText.text = "Missed"
				if fight_result:
					HitmakerText.text = "Hit"
					enemy_health -= player_attack
					decrease_enemy_health(player_attack)
					Sounds.hit.playing = true
				else:
					Sounds.missed.playing = true
				is_menuing = false
				animationplayer.play("hitmaker")
				await animationplayer.animation_finished
				if enemy_health <= 0:
					won()
					return
				is_menuing = true
			1:
				show_prompt("Przeciwnik:\nAtak: 1\nDefensywa: 0")
				await prompt_end

		await fight_player(1)
		if player_health <= 0:
			lost()
		else:
			is_menuing = true

func decrease_enemy_health(attack):
	var tween = create_tween()
	var calculations = EnemyHB.size.x - (44*attack)
	if calculations >= 0:
		tween.tween_property(EnemyHB, "size", Vector2(calculations, EnemyHB.size.y), 1)
	else:
		tween.tween_property(EnemyHB, "size", Vector2(0, EnemyHB.size.y), 1)

func fight_player(attack):
	is_menuing = false
	Hitmaker.position = Vector2(0, 0)
	HitmakerText.text = "Missed"
	var try = randi() % 3
	if try != 0:
		player_health -= attack
		HitmakerText.text = "Hit"
		Sounds.hit.playing = true
		var tween = create_tween()
		var calculations = PlayerHB.size.x - (55*attack)
		if calculations >= 0:
			tween.tween_property(PlayerHB, "size", Vector2(calculations, PlayerHB.size.y), 1)
		else:
			tween.tween_property(EnemyHB, "size", Vector2(0, PlayerHB.size.y), 1)
	else:
		Sounds.missed.playing = true
	animationplayer.play("hitmaker")
	await animationplayer.animation_finished
		
func won():
	global.is_alive = true
	animationplayer.play("won")
	await animationplayer.animation_finished
	end_battle.emit()
func lost():
	global.is_alive = false
	animationplayer.play("lost")
	await animationplayer.animation_finished
	end_battle.emit()

var fight_current_option = 0
signal answered
func fight():
	fight_current_option = 0
	MainNode.visible = false
	is_fighting = true
	var a = randi() % 7 + 3
	var b = randi() % 7 + 3
	var answer = a * b
	var question = "Ile wynosi wynik mnożenia liczb:\n" + str(a) + " * " + str(b)
	MathQuestionText.text = question
	var correct_button = randi() % 2
	MathQuestionButtonsText[correct_button].text = str(answer)
	var disctraction = randi() % 5 + 1
	if randi() % 2:
		disctraction = -disctraction
	MathQuestionButtonsText[abs(correct_button-1)].text = str(answer + disctraction)
	MathQuestionNode.visible = true
	animationplayer.speed_scale = 1.0/(len(question)/25.0)
	animationplayer.play("QuestionText")
	await answered
	is_fighting = false
	is_menuing = true
	MainNode.visible = true
	MathQuestionNode.visible = false
	var temp = fight_current_option
	fight_current_option = 0
	MathQuestionButtons[0].visible = true
	MathQuestionButtons[1].visible = false
	if temp == correct_button:
		return true
	else:
		return false

func handle_fight_buttons():
	if Input.is_action_just_pressed("down") and fight_current_option == 0:
		move_sound()
		MathQuestionButtons[fight_current_option].visible = false
		fight_current_option = 1
		MathQuestionButtons[fight_current_option].visible = true
	elif Input.is_action_just_pressed("up") and fight_current_option == 1:
		move_sound()
		MathQuestionButtons[fight_current_option].visible = false
		fight_current_option = 0
		MathQuestionButtons[fight_current_option].visible = true
	elif Input.is_action_just_pressed("enter"):
		confirm_sound()
		answered.emit()
	var random_number = randi() % 5
	if random_number == 3:
		return true
	else:
		return false
	
signal prompt_end
func show_prompt(text):
	is_prompting = true
	MainButtonsNode.visible = false
	PromptText.text = text
	animationplayer.speed_scale = 1.0/(len(text)/25.0)
	animationplayer.play("PromptText")
	dialog_sound()
	PromptNode.visible = true

func end_prompt():
	if Input.is_action_just_pressed("enter"):
		MainButtonsNode.visible = true
		PromptNode.visible = false
		animationplayer.stop()
		is_prompting = false
		is_menuing = true
		prompt_end.emit()
		confirm_sound()
	

func _process(_delta):
	if is_menuing:
		handle_main_buttons()
	elif is_prompting:
		end_prompt()
	elif is_fighting:
		handle_fight_buttons()


func _on_ready():
	start_battle.connect(_intro)
	end_battle.connect(_outro)
