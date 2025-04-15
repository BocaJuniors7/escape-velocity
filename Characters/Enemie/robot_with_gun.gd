extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_box: Area2D = $AttackBox
@onready var range_box: Area2D = $RangeBox  # Optional: create this like in the knife enemy
@onready var hitbox: Area2D = $HitBox
@onready var bullet_spawn: Marker2D = $BulletSpawn  # Create this node in your scene

@export var projectile_scene: PackedScene
@export var aim_duration := 0.4
@export var attack_cooldown := 1.0

var player = null
var is_attacking = false
var can_attack = true

func _ready():
	attack_box.connect("body_entered", _on_attackbox_body_entered)
	attack_box.connect("body_exited", _on_attackbox_body_exited)
	hitbox.connect("area_entered", _on_hitbox_area_entered)
	animated_sprite.play("Idle")

func _physics_process(_delta):
	if player and not is_attacking and can_attack:
		look_at(player.global_position)
		start_attack()

func _on_attackbox_body_entered(body):
	if body.name == "Player":
		print("👁️ Player entered shooting range.")
		player = body

func _on_attackbox_body_exited(body):
	if body == player:
		print("🚪 Player left shooting range.")
		player = null
		animated_sprite.play("Idle")

func _on_hitbox_area_entered(area):
	print("💥 Enemy hit by:", area.name)
	if area.name.contains("Bullet"):
		take_damage(10)

func take_damage(amount: int):
	animated_sprite.play("hit")
	# Add HP logic here if needed

func start_attack():
	is_attacking = true
	can_attack = false

	if player:
		look_at(player.global_position)
		animated_sprite.play("Aiming")
		await get_tree().create_timer(aim_duration).timeout

	# Check again if player is still valid and within range
	if player and range_box and range_box.overlaps_body(player):
		print("🎯 Firing at player")
		animated_sprite.play("Shooting")
		await animated_sprite.animation_finished

		if projectile_scene:
			var projectile = projectile_scene.instantiate()
			projectile.global_position = bullet_spawn.global_position
			projectile.direction = (player.global_position - global_position).normalized()
			get_tree().current_scene.add_child(projectile)
	else:
		print("🛡️ Player dodged shot")
		animated_sprite.play("Idle")

	is_attacking = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
