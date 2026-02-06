extends CharacterBody2D
class_name EnemyBase

@export var health: int = 3
@export var speed: int = 50
@export var damage: int = 1
@export var knockback_strength = 200.0 

@onready var sprite = $AnimatedSprite2D

var player: Node2D = null
var knockback_velocity = Vector2.ZERO

func _physics_process(delta):
	# Handle Knockback logic
	if knockback_velocity.length() > 10:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 800 * delta)
	elif player:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		update_animation(direction)
	else:
		velocity = Vector2.ZERO
		update_animation(Vector2.ZERO)
		
	# Call move_and_slide ONCE at the end
	move_and_slide()

func apply_knockback(from_position: Vector2):
	var bounce_dir = from_position.direction_to(global_position)
	knockback_velocity = bounce_dir * knockback_strength

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		queue_free()

func _on_detection_area_body_entered(body: Node2D):
	if body.name == "Player":
		player = body

func _on_detection_area_body_exited(body: Node2D):
	if body == player:
		player = null
		
func update_animation(direction: Vector2):
	if direction == Vector2.ZERO:
		sprite.play("idle_down")
		sprite.play("idle") 
		return
		
	# This logic checks if the enemy is moving more horizontally or vertically
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			sprite.play("run_right")
		else:
			sprite.play("run_left")
	else:
		if direction.y > 0:
			sprite.play("run_down")
		else:
			sprite.play("run_up")
