extends Area2D
@export var damage_amount: int = 1
func _on_area_entered(area: Area2D):
<<<<<<< HEAD
	print("I hit something: ", area.name)
	# Check if the area we hit belongs to an enemy's hurtbox
	if area.name == "enemy_hurtbox":
		print("I HIT THE SLIME!")
		var enemy = area.get_parent()
		if enemy.has_method("take_damage"):
			# Send the player's position to the enemy for direction calculation
			enemy.take_damage(damage, global_position)
=======
	print("DEBUG: Player sword hit: ", area.name)
	if area.has_method("take_damage"):
		area.take_damage(damage_amount, global_position)
>>>>>>> 99c0166312cc05e788bdc8bd02363b2229a5ace2
