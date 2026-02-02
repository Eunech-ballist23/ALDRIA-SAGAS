extends CharacterBody2D

@export var speed = 150
@onready var sprite = $AnimatedSprite2D

var last_direction = "down"
var is_attacking = false

func _ready():
	# This connects the sprite to the script so we know when the attack ends
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(_delta):
	# 1. Stop everything if we are currently attacking
	if is_attacking:
		return

	# 2. Check for Attack (Left Mouse Button)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		attack()
		return

	# 3. Manual Movement Inputs
	var direction = Vector2.ZERO
	if Input.is_action_pressed("right"):
		direction.x += 1
		last_direction = "right"
	elif Input.is_action_pressed("left"):
		direction.x -= 1
		last_direction = "left"
		
	if Input.is_action_pressed("down"):
		direction.y += 1
		last_direction = "down"
	elif Input.is_action_pressed("up"):
		direction.y -= 1
		last_direction = "up"

	# 4. Apply Movement
	velocity = direction.normalized() * speed
	move_and_slide()
	
	# 5. Play Movement Animations
	if direction != Vector2.ZERO:
		sprite.play("run_" + last_direction)
	else:
		sprite.play("idle_" + last_direction)

func attack():
	is_attacking = true
	velocity = Vector2.ZERO # Freeze movement during attack
	sprite.play("attack_" + last_direction)

func _on_animation_finished():
	# When the attack animation finishes, let the player move again
	if sprite.animation.begins_with("attack"):
		is_attacking = false
