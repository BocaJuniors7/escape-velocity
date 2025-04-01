extends Area2D

@export var speed: float = 1200.0
var direction: Vector2 = Vector2.ZERO

func _ready():
	connect("area_entered", _on_area_entered)

func _process(delta):
	position += direction * speed * delta

	#if not get_viewport_rect().has_point(global_position):
		#queue_free()

func _on_area_entered(area: Area2D) -> void:
	
	print("Layer:", area.collision_layer, " Mask:", area.collision_mask)

	print("🔍 Bullet collided with:", area.name, " (Group: ", area.get_groups(), ")")
	if area.name == "HitBox":

		print("📡 Bullet detected: ", area.name)
		#if area.get_parent().has_method("take_damage"):
			#area.get_parent().take_damage(10)
		queue_free()
