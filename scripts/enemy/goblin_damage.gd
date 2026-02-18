extends Area2D
<<<<<<< HEAD

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
=======
func _on_area_entered(area: Area2D):
	print("DEBUG: Enemy weapon hit: ", area.name)
	if area.has_method("take_damage"):
		area.take_damage(1, global_position)
>>>>>>> 99c0166312cc05e788bdc8bd02363b2229a5ace2
