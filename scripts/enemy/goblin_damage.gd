extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# 1. Push the Goblin away from the Player
		get_parent().apply_knockback(body.global_position)
		
		# 2. Push the Player away from the Goblin
		if body.has_method("apply_knockback"):
			body.apply_knockback(global_position)
