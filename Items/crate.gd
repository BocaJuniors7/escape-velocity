extends StaticBody2D

@export var max_health := 10
var current_health = max_health

@export var item_scenes: Array[PackedScene] = []  # Items to spawn
@onready var hit_box = $HitBox

func _ready():
	print("📦 Crate ready. HP =", current_health)
	hit_box.connect("area_entered", Callable(self, "_on_hit_box_area_entered"), CONNECT_DEFERRED)
	current_health = max_health  # Reset HP every time it's instanced

func _on_hit_box_area_entered(area: Area2D) -> void:
	print("📡 Area entered:", area.name)
	print("Layer:%s Mask:%s" % [str(area.collision_layer), str(area.collision_mask)])

	if area.name.contains("Bullet"):
		print("💥 Crate hit by bullet:", area.name)
		take_damage(10)
		area.queue_free()
	else:
		print("🛑 Not a bullet — ignoring.")

func take_damage(amount: int):
	current_health -= amount
	print("💢 Crate HP now:", current_health)

	if current_health <= 0:
		break_crate()
	else:
		print("🛡️ Crate still intact.")

@onready var spawn_points := $SpawnPoints.get_children()  # Node that holds all Marker2D

func break_crate():
	print("💥 Breaking crate... Spawning items:", item_scenes.size())
	for i in item_scenes.size():
		if i < spawn_points.size() and item_scenes[i]:
			var item = item_scenes[i].instantiate()
			get_parent().add_child(item)

			var spawn_marker = spawn_points[i]
			item.global_position = spawn_marker.global_position

			# Optional toss using Tween
			var toss_direction = spawn_marker.transform.y.normalized() * 27
			var target_pos = item.global_position + toss_direction

			var tween := get_tree().create_tween()
			tween.tween_property(item, "global_position", target_pos, 0.3)\
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

			print("🎁 Spawned item to:", target_pos)
		else:
			print("⚠️ No matching spawn point or scene!")
	queue_free()
