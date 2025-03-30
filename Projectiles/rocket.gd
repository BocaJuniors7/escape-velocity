extends Node2D

@export var speed := 300
var direction: Vector2 = Vector2.ZERO

func _process(delta):
	if direction != Vector2.ZERO:
		position += direction.normalized() * speed * delta
