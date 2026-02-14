extends CharacterBody2D
class_name Player

@export var max_health: int = 3
var current_health: int = max_health
@export var speed = 150

@onready var sprite = $AnimatedSprite2D

var last_direction = "down"
var is_attacking = false
var is_hurting = false
var is_dead = false 

func _ready():
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(_delta):
	# If dead, stop all inputs and movement
	if is_dead:
		return
		
	if is_attacking or is_hurting:
		return

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		attack()
		return

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

	velocity = direction.normalized() * speed
	move_and_slide()
	
	if direction != Vector2.ZERO:
		sprite.play("run_" + last_direction)
	else:
		sprite.play("idle_" + last_direction)

func attack():
	is_attacking = true
	velocity = Vector2.ZERO 
	sprite.play("attack_" + last_direction)

func _on_animation_finished():
	if sprite.animation.begins_with("attack"):
		is_attacking = false
	
	# Keep the player on the last frame of death
	if sprite.animation.begins_with("die"):
		sprite.stop() 

func take_damage(attacker_pos: Vector2):
	if is_hurting or is_dead: return 
	
	current_health -= 1
	is_attacking = false
	velocity = Vector2.ZERO
	
	var dir = attacker_pos.direction_to(global_position)
	
	if current_health <= 0:
		die(dir)
		return

	# Normal Hurt Logic
	is_hurting = true
	if abs(dir.x) > abs(dir.y):
		sprite.play("hurt_right" if dir.x > 0 else "hurt_left")
	else:
		sprite.play("hurt_down" if dir.y > 0 else "hurt_up") 
	
	await get_tree().create_timer(0.5).timeout 
	is_hurting = false 

func die(dir: Vector2):
	# Prevent multiple calls to die
	if is_dead: return
	
	is_dead = true
	velocity = Vector2.ZERO
	
	# Plays die animation based on hit direction
	if abs(dir.x) > abs(dir.y):
		sprite.play("die_right" if dir.x > 0 else "die_left")
	else:
		sprite.play("die_down" if dir.y > 0 else "die_up")
	
	# Start the restart timer
	restart_game()

func restart_game():
	# Wait for 2 seconds while the death animation/pose is visible
	await get_tree().create_timer(2.0).timeout
	
	# This resets the scene, variables, and positions
	get_tree().reload_current_scene()
