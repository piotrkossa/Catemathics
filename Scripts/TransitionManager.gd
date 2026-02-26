extends Node2D

signal transition
signal intro
signal on_half

signal white_transition
signal white_intro

@onready var TransitionPlayer = $AnimationPlayer
@onready var introRect = $CanvasLayer/intro
@onready var outroRect = $CanvasLayer/outro
@onready var w_introRect = $CanvasLayer/intro2
@onready var w_outroRect = $CanvasLayer/outro2

@onready var lightspeedsound = $lightspeedsound

func _on_ready():
	transition.connect(_on_transition)
	intro.connect(_on_intro)
	white_intro.connect(_on_white_intro)
	white_transition.connect(_on_white_transition)

func _on_white_intro():
	TransitionPlayer.stop()
	w_introRect.visible = true
	TransitionPlayer.play("white_intro")
	await TransitionPlayer.animation_finished
	w_introRect.visible = false
func _on_white_transition():
	lightspeedsound.playing = true
	TransitionPlayer.stop()
	TransitionPlayer.play("white_outro")
	w_outroRect.visible = true
	await TransitionPlayer.animation_finished
	on_half.emit()
	w_introRect.visible = true
	w_outroRect.visible = false
	w_outroRect.self_modulate = Color8(0, 0, 0, 0)
	TransitionPlayer.play("white_intro")
	await TransitionPlayer.animation_finished
	w_introRect.visible = false

func _on_transition():
	TransitionPlayer.stop()
	introRect.visible = false
	outroRect.visible = false
	TransitionPlayer.play("outro")
	outroRect.visible = true
	await TransitionPlayer.animation_finished
	on_half.emit()
	introRect.visible = true
	outroRect.visible = false
	outroRect.self_modulate = Color8(0, 0, 0, 0)
	TransitionPlayer.play("intro")
	await TransitionPlayer.animation_finished
	introRect.visible = false

func _on_intro():
	TransitionPlayer.stop()
	introRect.visible = true
	TransitionPlayer.play("intro")
	await TransitionPlayer.animation_finished
	introRect.visible = false
