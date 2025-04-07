extends Area2D

@export_file("*.tscn") var next_scene_path: String

func _ready():
	# Use connect with correct syntax
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	# Check if the body is the player
	if body.name == "Player":
		if next_scene_path != "":
			var next_scene = load(next_scene_path)
			if next_scene:
				# Use change_scene_to_file instead of change_scene_to_packed
				get_tree().change_scene_to_file(next_scene_path)
			else:
				print("Failed to load into the Portal")
		else:
			print("Next scene path incorrectly set")
