extends CharacterBody2D
class_name EnemyBase

# --- Configurable Variables ---
@export var health: int = 3
@export var speed: int = 50
@export var damage: int = 1
@export var knockback_strength: float = 200.0 

@export_group("Combat Settings")
@export var attack_range: float = 40.0
@export var attack_cancel_buffer: float = 15.0

@export_group("Wander Settings")
@export var wander_speed: int = 30
@export var wander_time_min: float = 1.0
@export var wander_time_max: float = 3.0
@export var idle_time_min: float = 1.0
@export var idle_time_max: float = 2.0
@export var stuck_threshold: float = 5.0 # Velocity below this triggers a direction change

@onready var sprite = $AnimatedSprite2D

# --- State Variables ---
var is_attacking: bool = false
var player: Node2D = null
var knockback_velocity: Vector2 = Vector2.ZERO

# Wander State Variables
var is_wandering: bool = false
var wander_direction: Vector2 = Vector2.ZERO
var state_timer: float = 0.0

# --- Initialization ---

func _ready():
	# Start by idling or wandering
	pick_new_state()

# --- Core Loop ---

func _physics_process(delta: float):
	# 1. Knockback Logic (High Priority)
	if knockback_velocity.length() > 10:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 800 * delta)
		move_and_slide()
		return 

	# 2. Attack Interrupt Check
	if is_attacking and player:
		var current_dist = global_position.distance_to(player.global_position)
		if current_dist > (attack_range + attack_cancel_buffer):
			is_attacking = false

	# 3. Decision Tree
	if is_attacking:
		velocity = Vector2.ZERO
	elif player:
		# --- COMBAT MODE ---
		process_combat_logic()
	else:
		# --- WANDER MODE ---
		process_wander_logic(delta)
		
	move_and_slide()

# --- Logic Modules ---

func process_combat_logic():
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player <= attack_range:
		start_attack()
	else:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		update_animation(direction)

func process_wander_logic(delta: float):
	state_timer -= delta
	
	if state_timer <= 0:
		pick_new_state()
	
	if is_wandering:
		velocity = wander_direction * wander_speed
		update_animation(wander_direction)
		
		# Stuck Check: If we are walking into a wall, pick a new direction
		# We wait a fraction of a second (0.2s) so we don't trigger it the instant we start
		if state_timer < (wander_time_max - 0.2):
			if get_real_velocity().length() < stuck_threshold:
				pick_new_state()
	else:
		velocity = Vector2.ZERO
		update_animation(Vector2.ZERO)

func pick_new_state():
	is_wandering = randf() > 0.5 # 50% chance to walk, 50% to idle
	
	if is_wandering:
		# Random direction (0 to 360 degrees)
		var angle = randf() * 2 * PI
		wander_direction = Vector2(cos(angle), sin(angle)).normalized()
		state_timer = randf_range(wander_time_min, wander_time_max)
	else:
		state_timer = randf_range(idle_time_min, idle_time_max)

# --- Combat Functions ---

func start_attack():
	if is_attacking: return
	is_attacking = true
	var dir = global_position.direction_to(player.global_position)
	play_directional_anim(dir, "attack")
	
func deal_damage_to_player():
	if player and player.has_method("take_damage"):
		var dist = global_position.distance_to(player.global_position)
		if dist <= attack_range:
			# Removed the quotes around global_position
			player.take_damage(global_position)

func apply_knockback(from_position: Vector2):
	var bounce_dir = from_position.direction_to(global_position)
	knockback_velocity = bounce_dir * knockback_strength
	is_attacking = false 

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		queue_free()

# --- Animation Handling ---

func update_animation(direction: Vector2):
	if direction == Vector2.ZERO:
		# Stay in the idle animation of the direction we were last facing
		if sprite.animation.contains("right"): 
			sprite.play("idle_right")
		elif sprite.animation.contains("left"): 
			sprite.play("idle_left")
		elif sprite.animation.contains("up"): 
			sprite.play("idle_up")
		else: 
			sprite.play("idle_down")
		return
		
	play_directional_anim(direction, "run")

func play_directional_anim(direction: Vector2, prefix: String):
	# Determines if horizontal or vertical movement is dominant
	if abs(direction.x) > abs(direction.y):
		sprite.play(prefix + ("_right" if direction.x > 0 else "_left"))
	else:
		sprite.play(prefix + ("_down" if direction.y > 0 else "_up"))

# --- Signals ---

func _on_animated_sprite_2d_animation_finished():
	if sprite.animation.begins_with("attack"):
		is_attacking = false

func _on_detection_area_body_entered(body: Node2D):
	if body.name == "Player":
		player = body

func _on_detection_area_body_exited(body: Node2D):
	if body == player:
		player = null
		pick_new_state() # Immediately start wandering when player leaves

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"): 
		if body.has_method("take_damage"):
			body.take_damage(global_position)
