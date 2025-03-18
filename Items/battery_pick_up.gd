extends Area2D

@export var battery_amount = 25.0  # Amount of battery to restore

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.add_battery(battery_amount)  # Add battery to player
		queue_free()  # Remove battery after pickup
