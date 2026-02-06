extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# 1. Make the SLIME bounce away from the player
		# get_parent() gets the root Slime node that has the apply_knockback function
		get_parent().apply_knockback(body.global_position)
		
		# 2. Make the PLAYER bounce away from the slime (optional)
	if body.has_method("apply_knockback"):
		body.apply_knockback(global_position)
