extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_box: Area2D = $AttackBox
@onready var hitbox: Area2D = $HitBox
@onready var rocket_spawn: Marker2D = $RocketSpawn # Add a Marker2D node as spawn point

@export var projectile_scene: PackedScene  # Assign rocket.tscn in the editor
@export var aim_duration := 1.5
@export var attack_cooldown := 2.5

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
		player = body

func _on_attackbox_body_exited(body):
	if body == player:
		player = null
		animated_sprite.play("Idle")

func _on_hitbox_area_entered(area):
	print("💥 Enemy hit by:", area.name)
	animated_sprite.play("hit")

func start_attack():
	is_attacking = true
	can_attack = false

	if player:
		look_at(player.global_position)
		animated_sprite.play("Aiming")
		await get_tree().create_timer(aim_duration).timeout

	if player:
		look_at(player.global_position)
		animated_sprite.play("Shooting")
		await animated_sprite.animation_finished

		if projectile_scene and rocket_spawn:
			var projectile = projectile_scene.instantiate()
			projectile.global_position = rocket_spawn.global_position
			projectile.direction = (player.global_position - rocket_spawn.global_position).normalized()
			get_tree().current_scene.add_child(projectile)
	else:
		animated_sprite.play("Idle")

	is_attacking = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
