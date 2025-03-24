extends Area2D

@export var battery_amount: float = 25.0

func _ready():
	body_entered.connect(_on_body_entered)

func _process(delta):
	# Simple rotation animation
	rotate(delta * 2)

func _on_body_entered(body):
	if body.is_in_group("player"):
		# If Preston has implemented a battery system, use:
		# body.add_battery(battery_amount)
		# Otherwise, just print for now:
		print("Collected battery: +" + str(battery_amount))
		queue_free()
