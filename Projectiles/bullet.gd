extends Area2D

@export var speed: float = 1200.0
var direction: Vector2 = Vector2.ZERO

func _ready():
	add_to_group("bullet")
	connect("area_entered", _on_area_entered)
	connect("body_entered", _on_body_entered)  # ✅ This is the key fix!

func _process(delta):
	position += direction * speed * delta

func _on_area_entered(area: Area2D) -> void:
	print("🔍 Bullet collided with AREA:", area.name)

	if area.name == "HitBox" and area.get_parent().has_method("take_damage"):
		print("💥 Bullet hit enemy!")
		#area.get_parent().take_damage(10)
		queue_free()

func _on_body_entered(body: Node) -> void:
	print("🧱 Bullet collided with BODY:", body.name)

	# Ignore player or items if needed
	if body.name == "Player":
		return

	# Optionally skip crates or pickups
	if body.is_in_group("pickup") or body.is_in_group("crate"):
		return

	# Otherwise, treat it as a wall or solid object
	print("💥 Bullet hit solid object. Removing.")
	queue_free()
