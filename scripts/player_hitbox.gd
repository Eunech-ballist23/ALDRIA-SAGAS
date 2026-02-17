extends Area2D

@export var damage: int = 1

func _ready():
	# Connect the signal to detect when the hitbox enters another area
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D):
	# Check if the area we hit belongs to an enemy's hurtbox
	if area.name == "enemy_hurtbox":
		var enemy = area.get_parent()
		if enemy.has_method("take_damage"):
			# Send the player's position to the enemy for direction calculation
			enemy.take_damage(damage, global_position)
