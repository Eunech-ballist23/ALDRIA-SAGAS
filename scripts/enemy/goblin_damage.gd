extends Area2D

@export var damage: int = 1

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# 1. Push the Goblin away from the Player (Self-knockback)
		get_parent().apply_knockback(body.global_position)
		
		# 2. Hurt the Player!
		# We call take_damage instead of apply_knockback, 
		# because your Player script handles the "hurt" logic inside take_damage.
		if body.has_method("take_damage"):
			body.take_damage(global_position)
