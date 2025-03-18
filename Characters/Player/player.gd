extends CharacterBody2D

# Variables
@export var max_battery = 100.0
@export var battery_drain_rate = 2.0
var battery_level = 100.0
@export var speed = 400.0

# HUD Reference
@onready var hud: CanvasLayer = null
@onready var player_light: Light2D = $PlayerLight  # Reference to the player's light

# Shooting variables
@export var bullet_scene: PackedScene = preload("res://Projectiles/bullet.tscn")
@export var shoot_cooldown: float = 0.2
var can_shoot: bool = true

# Reference to GunPoint (bullet spawn position)
@onready var gun_point = $GunPoint

func _ready():
	# Find HUD dynamically
	hud = get_tree().current_scene.find_child("HUD", true, false)

	# Debugging - Check if HUD is found
	if hud:
		print("✅ HUD FOUND!")
	else:
		print("❌ HUD NOT FOUND! Check scene structure.")

	# Ensure HUD updates when the player spawns
	update_hud()

func _physics_process(delta):
	# Get input direction
	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	
	# Normalize for consistent speed in diagonals
	if direction != Vector2.ZERO:
		direction = direction.normalized()

	# Move the character
	velocity = direction * speed
	move_and_slide()

	# Rotate to face the mouse (affects visuals, not shooting)
	var mouse_direction = (get_global_mouse_position() - global_position).normalized()
	rotation = mouse_direction.angle()

	# Battery drain over time
	battery_level -= battery_drain_rate * delta
	battery_level = max(battery_level, 0)

	# Update Light Intensity
	update_light_intensity()

	# Update HUD
	update_hud()

func _input(event):
	if event is InputEventMouseButton and event.pressed and can_shoot:
		shoot()
		can_shoot = false
		await get_tree().create_timer(shoot_cooldown).timeout
		can_shoot = true

func shoot():
	if not bullet_scene:
		return  # Prevent errors if the bullet scene is missing

	var bullet = bullet_scene.instantiate()  # Create the bullet instance
	get_parent().add_child(bullet)

	# Set bullet position to GunPoint
	bullet.global_position = gun_point.global_position

	# Set bullet direction independently of player rotation
	var shoot_direction = (get_global_mouse_position() - gun_point.global_position).normalized()
	bullet.direction = shoot_direction

	# Rotate bullet to face the correct direction
	bullet.rotation = shoot_direction.angle()

# Function to add battery power and update HUD
func add_battery(amount):
	battery_level = min(battery_level + amount, max_battery)
	update_light_intensity()  # Update light when battery is recharged
	update_hud()

# Function to update HUD battery display
func update_hud():
	if hud == null:
		print("⚠️ HUD is null! Skipping update.")
		return  # Prevents crashing

	if hud.has_method("update_battery"):
		hud.update_battery(battery_level, max_battery)
	else:
		print("⚠️ HUD found but function update_battery() is missing!")

# Function to adjust light intensity based on battery level
func update_light_intensity():
	if player_light:
		var light_intensity = battery_level / max_battery  # Scale between 0 and 1
		player_light.energy = light_intensity  # Adjust light brightness

		# If battery is 0, turn off the light
		if battery_level <= 0:
			player_light.visible = false
		else:
			player_light.visible = true
