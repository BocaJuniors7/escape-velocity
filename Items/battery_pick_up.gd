extends Area2D

@export var battery_amount = 25.0

func _ready():
	connect("body_entered", _on_area_2d_body_entered)




func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("🔋 Battery collected!")
		if body.has_method("add_battery"):
			body.add_battery(battery_amount)
		queue_free()
