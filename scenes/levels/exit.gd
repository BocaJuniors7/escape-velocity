extends Area2D

@export_file("*.tscn") var next_scene_path: String

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		if next_scene_path != "":
			# Save player state before leaving
			body.on_level_completed()
			# Transition to the next level
			get_tree().change_scene_to_file(next_scene_path)
		else:
			print("❌ Next scene path not set properly.")
