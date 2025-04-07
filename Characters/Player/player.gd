extends CharacterBody2D

# Variables
@export var max_battery = 100.0
@export var battery_drain_rate = 2.0
var battery_level = 100.0
@export var speed = 200.0
@export var max_health := 100
var current_health = max_health

# HUD Reference
@onready var hud: CanvasLayer = null
@onready var player_light: Light2D = $PlayerLight
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox = $HitBox

# Shooting variables
@export var bullet_scene: PackedScene = preload("res://Projectiles/bullet.tscn")
@export var shoot_cooldown: float = 0.2
var can_shoot: bool = true

# Gun / Reload variables
var ammo = 10
var max_ammo = 10
var is_reloading = false

# Reference to GunPoint (bullet spawn position)
@onready var gun_point = $GunPoint


func _ready():
	hud = get_tree().current_scene.find_child("HUD", true, false)  # ✅ fixed name

	if hud:
		print("✅ HUD FOUND!")
	else:
		print("❌ HUD NOT FOUND! Check scene structure.")

	update_hud()

	if hitbox:
		hitbox.connect("area_entered", _on_hitbox_area_entered)


func _physics_process(delta):
	# Movement input
	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	if direction != Vector2.ZERO:
		direction = direction.normalized()

	velocity = direction * speed
	move_and_slide()

	# 🔥 Ensure run animation is always playing if not overridden
	if animated_sprite.animation != "run" and not animated_sprite.is_playing():
		animated_sprite.play("run")

	# Face the mouse
	var mouse_direction = (get_global_mouse_position() - global_position).normalized()
	rotation = mouse_direction.angle()

	# Battery logic
	battery_level -= battery_drain_rate * delta
	battery_level = max(battery_level, 0)

	update_light_intensity()
	update_hud()

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if ammo > 0 and not is_reloading and can_shoot:
			can_shoot = false  # 🔒 Prevent spamming before animation
			ammo -= 1
			await shoot()
			await get_tree().create_timer(shoot_cooldown).timeout
			can_shoot = true
		elif not is_reloading and can_shoot:
			can_shoot = false  # 🔒 Still block inputs if reloading is triggered
			await reload()
			can_shoot = true


# 🔥 Called when hitbox detects a collision
func _on_hitbox_area_entered(area):
	print("💥 Player hit by: ", area.name)
	take_damage()

# 🔥 Play hit animation
func take_damage(amount := 10):
	current_health -= amount
	print("🔥 Player took damage! HP =", current_health)
	animated_sprite.play("hit")

	if hud and hud.has_method("update_health"):
		hud.update_health(current_health, max_health)

	if current_health <= 0:
		die()

func shoot() -> void:
	if not bullet_scene:
		return

	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)

	bullet.global_position = gun_point.global_position
	var shoot_direction = (get_global_mouse_position() - gun_point.global_position).normalized()
	bullet.direction = shoot_direction
	bullet.rotation = shoot_direction.angle()

	# 🔥 Play hipfire animation, then return to run
	animated_sprite.play("hipFire")
	await animated_sprite.animation_finished
	if not is_reloading:
		animated_sprite.play("run")

func reload() -> void:
	if ammo == max_ammo or is_reloading:
		return

	is_reloading = true
	animated_sprite.play("reload")
	await animated_sprite.animation_finished
	ammo = max_ammo
	is_reloading = false
	animated_sprite.play("run")

func add_battery(amount):
	battery_level = min(battery_level + amount, max_battery)
	update_light_intensity()
	update_hud()

func update_hud():
	if hud == null:
		print("⚠️ HUD is null! Skipping update.")
		return

	if hud.has_method("update_battery"):
		hud.update_battery(battery_level, max_battery)
	else:
		print("⚠️ HUD found but function update_battery() is missing!")

func update_light_intensity():
	if player_light:
		var light_intensity = battery_level / max_battery
		player_light.energy = light_intensity
		player_light.visible = battery_level > 0
		
func die():
	print("☠️ Player died!")
	queue_free()  # You can replace this with a respawn or Game Over screen
	
func add_health(amount: int):
	current_health = min(current_health + amount, max_health)
	print("💚 Player healed! HP =", current_health)

	if hud and hud.has_method("update_health"):
		hud.update_health(current_health, max_health)


func _on_level_2_entrance_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
