extends Area2D

@export var heal_amount := 25  # Amount of health to restore

func _ready():
	connect("body_entered", _on_area_2d_body_entered)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and body.has_method("add_health"):
		print("❤️ Player picked up health pack")
		body.add_health(heal_amount)
		queue_free()  # Remove the health pack after pickup
