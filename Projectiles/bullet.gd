extends Area2D

@export var speed: float = 1200.0  # Adjust as needed
var direction: Vector2 = Vector2.ZERO

func _process(delta):
	position += direction * speed * delta

	# Remove if off screen
	if not get_viewport_rect().has_point(global_position):
		queue_free()
