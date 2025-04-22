extends Area2D

@export_file("*.tscn") var next_scene_path: String

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		# 💾 Save current health/battery into GameState
		GameState.player_health = body.current_health
		GameState.player_battery = body.battery_level
		print("💾 Saved: HP =", body.current_health, " Battery =", body.battery_level)

		# 🌌 Then transition
		get_tree().change_scene_to_file(next_scene_path)
