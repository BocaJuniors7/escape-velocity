extends Area2D

@export var energy_amount := 50.0  # Half of full battery (assuming full is 100)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and body.has_method("add_battery"):
		body.add_battery(energy_amount)
		print("🔋 Half battery picked up! +" + str(energy_amount))
		queue_free()  # Remove the pickup after use
