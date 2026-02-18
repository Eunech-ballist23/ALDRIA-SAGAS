extends CharacterBody2D
class_name EnemyBase

@export var health: int = 3
@export var speed: int = 50
@export var knockback_strength: float = 150.0 
@export var attack_range: float = 40.0
@export var hitbox_shape: CollisionShape2D 

@onready var sprite = $AnimatedSprite2D

var is_attacking: bool = false
var is_hurting: bool = false 
var is_dead: bool = false    
var player: Node2D = null
var knockback_velocity: Vector2 = Vector2.ZERO
<<<<<<< HEAD

var is_hurting: bool = false

# Wander State Variables
=======
>>>>>>> 99c0166312cc05e788bdc8bd02363b2229a5ace2
var is_wandering: bool = false
var wander_direction: Vector2 = Vector2.ZERO
var state_timer: float = 0.0

func _ready():
	pick_new_state()
	if hitbox_shape:
		hitbox_shape.set_deferred("disabled", true)

func _physics_process(delta: float):
<<<<<<< HEAD
	
	# 2. ADD THIS CHECK
	# If we are hurting, don't move or change states
	if is_hurting:
		move_and_slide() # Allow the knockback to slide us, but don't run logic
		return
	
	# 1. Knockback Logic (High Priority)
=======
	if is_dead: return
	
>>>>>>> 99c0166312cc05e788bdc8bd02363b2229a5ace2
	if knockback_velocity.length() > 10:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 800 * delta)
		move_and_slide()
<<<<<<< HEAD
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

func take_damage(amount: int, attacker_pos: Vector2 = Vector2.ZERO):
	if is_hurting: return # Prevent stun-lock if hit twice instantly
	
	health -= amount
	
	# 3. PLAY THE HURT ANIMATION
	is_hurting = true
	
	# Calculate direction from attacker to slime to know which side was hit
	var dir = attacker_pos.direction_to(global_position)
	
	# Play the correct hurt animation based on direction
	if abs(dir.x) > abs(dir.y):
		sprite.play("hurt_right" if dir.x > 0 else "hurt_left")
	else:
		sprite.play("hurt_down" if dir.y > 0 else "hurt_up")
	
	# If we received a position, apply knockback
	if attacker_pos != Vector2.ZERO:
		apply_knockback(attacker_pos)

	if health <= 0:
		# Add a small delay so we see the hurt frame before it vanishes
		# Or play a "die" animation if you have one
		await get_tree().create_timer(0.2).timeout
		queue_free()
	else:
		# 4. RECOVER FROM HURT
		# Wait for the animation to finish (approx 0.4s)
		await get_tree().create_timer(0.4).timeout
		is_hurting = false
		pick_new_state() # Go back to wandering/chasing

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
=======
>>>>>>> 99c0166312cc05e788bdc8bd02363b2229a5ace2
		return
		
	# While hurting or attacking, the enemy stays still
	if is_hurting or is_attacking:
		velocity = Vector2.ZERO
	elif player:
		process_combat_logic()
	else:
		process_wander_logic(delta)
	move_and_slide()

func process_combat_logic():
	var dist = global_position.distance_to(player.global_position)
	if dist <= attack_range:
		start_attack()
	else:
		var dir = global_position.direction_to(player.global_position)
		velocity = dir * speed
		update_animation(dir)

func start_attack():
	# If already hurting, don't start a new attack
	if is_attacking or is_hurting or is_dead: return
	
	is_attacking = true
	var dir_name = get_direction_name(global_position.direction_to(player.global_position))
	sprite.play("attack_" + dir_name)
	
	# Delay damage to match the visual swing frame
	await get_tree().create_timer(0.2).timeout 
	
	# RE-CHECK: If the enemy was hit (is_hurting) during the timer, don't enable the hitbox
	if is_attacking and not is_hurting and not is_dead and hitbox_shape:
		hitbox_shape.set_deferred("disabled", false)

func take_damage(amount: int, attacker_pos: Vector2):
	if is_dead: return
	
	# --- ATTACK CANCEL LOGIC ---
	is_hurting = true
	is_attacking = false # Force attack state to false
	
	# Immediately stop the attack animation and disable the hitbox
	sprite.stop() 
	if hitbox_shape: 
		hitbox_shape.set_deferred("disabled", true)
	# ---------------------------

	health -= amount
	flash_red()
	apply_knockback(attacker_pos)
	
	var dir_name = get_direction_name(attacker_pos.direction_to(global_position))
	
	if health <= 0:
		is_dead = true
		sprite.play("death_" + dir_name)
	else:
		sprite.play("hurt_" + dir_name)

func flash_red():
	sprite.modulate = Color(10, 1, 1)
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.2)

func apply_knockback(from_pos: Vector2):
	knockback_velocity = from_pos.direction_to(global_position) * knockback_strength

func update_animation(dir: Vector2):
	if dir == Vector2.ZERO: return
	sprite.play("run_" + get_direction_name(dir))

func get_direction_name(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0 else "left"
	return "down" if dir.y > 0 else "up"

func process_wander_logic(delta):
	state_timer -= delta
	if state_timer <= 0: pick_new_state()
	if is_wandering:
		velocity = wander_direction * (speed * 0.6)
		update_animation(wander_direction)
	else:
		velocity = Vector2.ZERO

func pick_new_state():
	is_wandering = randf() > 0.5
	state_timer = randf_range(1.0, 3.0)
	wander_direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()

func _on_animated_sprite_2d_animation_finished():
	var anim = sprite.animation
	if anim.begins_with("attack"):
		is_attacking = false
		if hitbox_shape: 
			hitbox_shape.set_deferred("disabled", true)
	elif anim.begins_with("hurt"):
		is_hurting = false # Enemy is now ready to attack again
	elif anim.begins_with("death"):
		queue_free()

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"): player = body

func _on_detection_area_body_exited(body):
	if body == player: player = null
