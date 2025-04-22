extends CharacterBody2D

@onready var shooting_audio: AudioStreamPlayer2D = $ShootingAudio
@onready var reloading_audio: AudioStreamPlayer2D = $ReloadingAudio
@onready var health_audio: AudioStreamPlayer2D = $HealthAddedAudio
@onready var battery_audio: AudioStreamPlayer2D = $BatteryAddedAudio

@export var max_battery = 100.0
@export var battery_drain_rate = 2.5
var battery_level = 100.0
@export var speed = 200.0
@export var max_health := 100
var current_health = max_health

@onready var hud: CanvasLayer = null
@onready var player_light: PointLight2D = $PlayerLight
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox = $HitBox

@export var bullet_scene: PackedScene = preload("res://Projectiles/bullet.tscn")
@export var shoot_cooldown: float = 0.2
var can_shoot: bool = true

var ammo = 10
var max_ammo = 10
var is_reloading = false

@onready var gun_point = $GunPoint

func _ready():
	current_health = GameState.player_health
	battery_level = GameState.player_battery
	ammo = 10  # Ensure it's set properly here
	max_ammo = 10
	print("🧐 GameState at start: HP =", current_health, " Battery =", battery_level)
	hud = get_tree().current_scene.find_child("HUD", true, false)

	if hud:
		print("✅ HUD FOUND!")
	else:
		print("❌ HUD NOT FOUND! Check scene structure.")

	if Engine.has_singleton("GameState"):
		var state = Engine.get_singleton("GameState")
		if state.player_health > 0:
			current_health = state.player_health
		if state.player_battery >= 0:
			battery_level = state.player_battery
		print("🔄 Loaded player state: HP =", current_health, ", Battery =", battery_level)

	update_hud()
	update_ammo_display()

	if hitbox:
		hitbox.connect("area_entered", _on_hitbox_area_entered)

func _physics_process(delta):
	var direction = Vector2.ZERO
	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1
	if Input.is_action_pressed("up"):
		direction.y -= 1

	if direction != Vector2.ZERO:
		direction = direction.normalized()

	velocity = direction * speed
	move_and_slide()

	if animated_sprite.animation != "run" and not animated_sprite.is_playing():
		animated_sprite.play("run")

	var mouse_direction = (get_global_mouse_position() - global_position).normalized()
	rotation = mouse_direction.angle()

	battery_level -= battery_drain_rate * delta
	battery_level = max(battery_level, 0)

	update_light_intensity()
	update_hud()

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if is_reloading:
			return
		if ammo <= 0:
			await reload()
			return
		if can_shoot:
			can_shoot = false
			ammo -= 1
			update_ammo_display()
			await shoot()
			if ammo <= 0 and not is_reloading:
				await reload()
			else:
				await get_tree().create_timer(shoot_cooldown).timeout
				can_shoot = true

func shoot() -> void:
	shooting_audio.play()
	if bullet_scene == null:
		print("❌ Bullet scene is null!")
		return

	var bullet = bullet_scene.instantiate()
	if not bullet:
		print("❌ Bullet instantiation failed!")
		return

	get_parent().add_child(bullet)
	bullet.global_position = gun_point.global_position
	var shoot_direction = (get_global_mouse_position() - gun_point.global_position).normalized()
	bullet.direction = shoot_direction
	bullet.rotation = shoot_direction.angle()
	animated_sprite.play("hipFire")
	await animated_sprite.animation_finished

	if not is_reloading:
		animated_sprite.play("run")

func reload() -> void:
	if ammo == max_ammo or is_reloading:
		return
	is_reloading = true
	reloading_audio.play()
	animated_sprite.play("reload")
	await animated_sprite.animation_finished
	ammo = max_ammo
	is_reloading = false
	can_shoot = true
	update_ammo_display()
	animated_sprite.play("run")

func _on_hitbox_area_entered(area):
	print("💥 Player hit by: ", area.name)
	if area.name.contains("AttackBox") or area.get_parent().name.contains("Enemy"):
		print("🛡️ Ignored damage from enemy attack box")
		return
	take_damage()

func take_damage(amount := 10):
	current_health -= amount
	print("🔥 Player took damage! HP =", current_health)
	animated_sprite.play("hit")
	if hud and hud.has_method("update_health"):
		hud.update_health(current_health, max_health)
	if current_health <= 0:
		die()

func add_health(amount: int):
	current_health = min(current_health + amount, max_health)
	print("💚 Player healed! HP =", current_health)
	if health_audio:
		health_audio.play()
	if hud and hud.has_method("update_health"):
		hud.update_health(current_health, max_health)

func die():
	print("☠️ Player died!")
	queue_free()

func add_battery(amount):
	battery_level = min(battery_level + amount, max_battery)
	if battery_audio:
		battery_audio.play()
	update_light_intensity()
	update_hud()

func update_light_intensity():
	if player_light:
		var light_intensity = battery_level / max_battery
		player_light.energy = light_intensity
		player_light.visible = battery_level > 0

func update_hud():
	if hud == null:
		print("⚠️ HUD is null! Skipping update.")
		return
	if hud.has_method("update_battery"):
		hud.update_battery(battery_level, max_battery)
	else:
		print("⚠️ HUD missing update_battery()")
	if hud.has_method("update_health"):
		hud.update_health(current_health, max_health)
	else:
		print("⚠️ HUD missing update_health()")

func update_ammo_display():
	if hud and hud.has_method("update_ammo"):
		hud.update_ammo(ammo, max_ammo)

func _on_level_2_entrance_body_entered(body: Node2D) -> void:
	pass

func on_level_completed():
	GameState.player_health = current_health
	GameState.player_battery = battery_level
	print("💾 Player state saved: HP =", current_health, ", Battery =", battery_level)
