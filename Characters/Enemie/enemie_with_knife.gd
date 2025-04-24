extends CharacterBody2D

@onready var damage_audio: AudioStreamPlayer2D = $DamageAudio
@onready var death_audio: AudioStreamPlayer2D = $DeathAudio
@onready var growling_audio: AudioStreamPlayer2D = $GrowlingAudio
@onready var attacking_audio: AudioStreamPlayer2D = $AttackingAudio

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_box: Area2D = $AttackBox
@onready var hitbox: Area2D = $HitBox
@onready var detection_area: Area2D = $DetectionArea

@export var attack_cooldown := 0.5
@export var max_health := 20
@export var move_speed := 100.0

var current_health = max_health
var player = null
var is_attacking = false
var can_attack = true
var use_slash_next = true

func _ready():
	if detection_area:
		detection_area.connect("body_entered", _on_detection_area_body_entered)
		detection_area.connect("body_exited", _on_detection_area_body_exited)

	if attack_box and attack_box.has_signal("body_entered"):
		print("✅ AttackBox signal is valid (manually connected).")
	else:
		print("❌ AttackBox missing or signal not found!")

	if hitbox:
		print("✅ HitBox connected.")
		hitbox.connect("area_entered", _on_hitbox_area_entered)

	animated_sprite.play("run")
	print("🏃 Enemy ready and idle.")

func _physics_process(delta):
	if player:
		look_at(player.global_position)

		if not is_attacking:
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * move_speed
			move_and_slide()

		if not is_attacking and can_attack and attack_box.overlaps_body(player):
			print("⚔️ Initiating attack...")
			attack()
	else:
		velocity = Vector2.ZERO
		move_and_slide()

func attack():
	is_attacking = true
	can_attack = false

	if player:
		look_at(player.global_position)

	var animation_name = "slash" if use_slash_next else "thrust"
	use_slash_next = !use_slash_next

	print("🎬 Playing attack animation:", animation_name)

	# Play attacking audio at start of animation
	attacking_audio.pitch_scale = randf_range(0.95, 1.05)
	attacking_audio.play()

	animated_sprite.play(animation_name)
	await animated_sprite.animation_finished
	print("✅ Finished", animation_name, "animation.")

	if player and $RangeBox.overlaps_body(player):
		print("💥 Enemy deals damage to player!")
		if player.has_method("take_damage"):
			player.take_damage(10)
	else:
		print("🛡️ Player dodged the attack")
	
	if not is_inside_tree() or is_queued_for_deletion():
		return  # Prevent further actions if scene is about to change
	
	
	if player:
		animated_sprite.play("run")

	is_attacking = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

	# 🔁 Immediately re-attack if still in range
	if player and attack_box.overlaps_body(player):
		attack()


func _on_hitbox_area_entered(area):
	print("💥 Player hit by:", area.name)

	if area.name.contains("AttackBox"):
		print("🛡️ Ignored damage from AttackBox overlap")
		return

	take_damage(10)

func take_damage(amount: int):
	if not damage_audio.playing:
		damage_audio.pitch_scale = randf_range(0.95, 1.05)
		damage_audio.play()

	current_health -= amount
	print("💢 Enemy took", amount, "damage! HP =", current_health)

	animated_sprite.play("hit")

	if current_health <= 0:
		die()

func die():
	print("💀 Enemy died!")

	# Disable colliders and visibility
	if $CollisionShape2D:
		$CollisionShape2D.disabled = true
	if $HitBox:
		$HitBox.monitoring = false
		$HitBox.set_deferred("monitorable", false)
	if $AttackBox:
		$AttackBox.monitoring = false
		$AttackBox.set_deferred("monitorable", false)
	visible = false  # Hide the enemy sprite

	# Detach death audio from enemy node and let it play
	var death_audio_copy = death_audio.duplicate()
	get_parent().add_child(death_audio_copy)
	death_audio_copy.global_position = global_position
	death_audio_copy.pitch_scale = randf_range(2.95, 3.05)
	death_audio_copy.play()

	# Free the enemy node immediately, audio will still play
	queue_free()

	# Correct Godot 4 syntax for connecting signal
	death_audio_copy.finished.connect(death_audio_copy.queue_free)





func _on_attack_box_body_entered(_body: Node2D) -> void:
	print("📥 Player entered AttackBox (debug log)")

func _on_attack_box_body_exited(_body: Node2D) -> void:
	print("🚪 Player exited the AttackBox (debug log)")

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if not growling_audio.playing:
			growling_audio.pitch_scale = randf_range(0.95, 1.05)
			growling_audio.play()

		print("👁️ Player entered vision range")
		player = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player and not attack_box.overlaps_body(body):
		print("🚶‍♂️ Player left vision range")
		player = null
