class_name SceneTrigger extends Area2D

@export var connected_scene: String
var scene_folder = "res://scenes/"

func _on_body_entered(body: Node2D) -> void:
	var full_path = scene_folder + connected_scene + ".tscn"
	var scene_tree = get_tree()	
	
