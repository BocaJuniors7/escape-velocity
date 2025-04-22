extends StaticBody2D
@onready var breaking_audio: AudioStreamPlayer2D = $BreakingAudio
@export var max_health := 10
var current_health = max_health

@export var item_scenes: Array[PackedScene] = []  # Items to spawn
@onready var hit_box = $HitBox
@onready var spawn_points := $SpawnPoints.get_children()  # Node that holds all Marker2D

func _ready():
	current_health = max_health  # ✅ Ensure health is reset first
	print("📦 Crate ready. HP =", current_health)

	# ✅ Ensure hitbox is actively detecting
	hit_box.monitoring = true
	hit_box.monitorable = true

	# ✅ Connect hitbox for bullet detection (non-blocking, safe)
	hit_box.connect("area_entered", Callable(self, "_on_hit_box_area_entered"), CONNECT_DEFERRED)

func _on_hit_box_area_entered(area: Area2D) -> void:
	print("📡 Area entered:", area.name)
	print("Layer:%s Mask:%s" % [str(area.collision_layer), str(area.collision_mask)])

	# ✅ Use group check instead of name
	if area.is_in_group("bullet"):
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

func break_crate():
	print("💥 Breaking crate... Spawning items:", item_scenes.size())

	# 🎧 Detach the audio before freeing the crate
	if breaking_audio:
		var detached_audio = breaking_audio.duplicate()
		get_tree().current_scene.add_child(detached_audio)
		detached_audio.global_position = global_position
		detached_audio.pitch_scale = randf_range(0.95, 1.05)
		detached_audio.play()

		# 💡 Free the audio after it's done
		detached_audio.connect("finished", detached_audio.queue_free)

	# 🎁 Spawn items as usual
	for i in item_scenes.size():
		if i < spawn_points.size() and item_scenes[i]:
			var item = item_scenes[i].instantiate()
			get_parent().add_child(item)

			var spawn_marker = spawn_points[i]
			item.global_position = spawn_marker.global_position

			var toss_direction = spawn_marker.transform.y.normalized() * 27
			var target_pos = item.global_position + toss_direction

			var tween := get_tree().create_tween()
			tween.tween_property(item, "global_position", target_pos, 0.3)\
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

			print("🎁 Spawned item to:", target_pos)
		else:
			print("⚠️ No matching spawn point or scene!")

	print("🧹 Crate removed from scene.")
	queue_free()
