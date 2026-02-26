extends CharacterBody2D

var speed = 200

@onready var sprite = $Sprite
var previous_rotation = "left_idle"
var is_inter_prompt_active = false

signal interaction(name)
signal interaction_prompt(is_active)
signal stop_process
signal devmode_changed


func _on_ready():
	if global.dev_mode:
		speed = 1000
	stop_process.connect(_stop_process)
	devmode_changed.connect(_change_dev_speed)

func _change_dev_speed():
	if global.dev_mode:
		speed = 1000
	else:
		speed = 200

func _stop_process():
	sprite.animation = previous_rotation
	process_mode = Node.PROCESS_MODE_DISABLED

func handle_moving():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	
	if input_direction.x == 0 and input_direction.y == 0:
		sprite.animation = previous_rotation
	elif input_direction.y > 0:
		sprite.animation = "front_active"
		previous_rotation = "front_idle"
	elif input_direction.y < 0:
		sprite.animation = "back_active"
		previous_rotation = "back_idle"
	else:
		if input_direction.x > 0:
			previous_rotation = "right_idle"
			sprite.animation = "right_active"
		else:
			previous_rotation = "left_idle"
			sprite.animation = "left_active"
	velocity = input_direction * speed
	move_and_slide()

func handle_interactions():
	var is_in_range = false
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i).get_collider()
		if collision.is_in_group("Interactable"):
			interaction.emit(collision.name)
			is_in_range = true
			break
	if is_in_range:
		if not is_inter_prompt_active:
			is_inter_prompt_active = true
			interaction_prompt.emit(true)
	else:
		if is_inter_prompt_active:
			is_inter_prompt_active = false
			interaction_prompt.emit(false)

func _physics_process(_delta):
	handle_moving()
	handle_interactions()
