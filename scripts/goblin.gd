extends CharacterBody2D

@export var speed = 50.0
@export var detection_range = 120.0
@export var attack_range = 25.0

@onready var sprite = $AnimatedSprite2D
@onready var player = get_tree().get_first_node_in_group("player")

var current_state = "idle"
var direction = "down"

func _physics_process(_delta):
	if current_state == "death" or current_state == "hurt":
		return

	if player:
		var distance = global_position.distance_to(player.global_position)
		var target_dir = (player.global_position - global_position).normalized()

		# 1. State Logic for Detection and Combat
		if distance <= attack_range:
			current_state = "attack"
			velocity = Vector2.ZERO 
		elif distance <= detection_range:
			current_state = "run"
			velocity = target_dir * speed
			_update_direction(target_dir)
		else:
			current_state = "idle"
			velocity = Vector2.ZERO

	move_and_slide()
	_play_directional_animation()

func _update_direction(target_vector: Vector2):
	# Determine 4-way direction based on movement vector
	if abs(target_vector.x) > abs(target_vector.y):
		direction = "right" if target_vector.x > 0 else "left"
	else:
		direction = "down" if target_vector.y > 0 else "up"

func _play_directional_animation():
	# Construct string to match your SpriteFrames (e.g., "run_down")
	var anim_name = current_state + "_" + direction
	if sprite.animation != anim_name:
		sprite.play(anim_name)

# Call these for reactions
func take_damage():
	current_state = "hurt"
	await sprite.animation_finished
	current_state = "idle"

func die():
	current_state = "death"
	set_physics_process(false)
