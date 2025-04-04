extends CharacterBody2D

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
	animated_sprite.play(animation_name)

	await animated_sprite.animation_finished
	print("✅ Finished", animation_name, "animation.")

	# 🔥 Check if player is still in RANGE after attack anim
	if player and $RangeBox.overlaps_body(player):
		print("💥 Enemy deals damage to player!")
		if player.has_method("take_damage"):
			player.take_damage(10)
	else:
		print("🛡️ Player dodged the attack")

	if player:
		animated_sprite.play("run")

	is_attacking = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _on_hitbox_area_entered(area):
	print("💥 Player hit by:", area.name)

	if area.name.contains("AttackBox"):
		print("🛡️ Ignored damage from AttackBox overlap")
		return

	take_damage(10)



func take_damage(amount: int):
	current_health -= amount
	print("💢 Enemy took", amount, "damage! HP =", current_health)

	animated_sprite.play("hit")

	if current_health <= 0:
		die()

func die():
	print("💀 Enemy died!")
	queue_free()

# ✅ Removed damage logic and player setting from attack box signals
func _on_attack_box_body_entered(_body: Node2D) -> void:
	print("📥 Player entered AttackBox (debug log)")

func _on_attack_box_body_exited(_body: Node2D) -> void:
	print("🚪 Player exited the AttackBox (debug log)")

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("👁️ Player entered vision range")
		player = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player and not attack_box.overlaps_body(body):
		print("🚶‍♂️ Player left vision range")
		player = null
