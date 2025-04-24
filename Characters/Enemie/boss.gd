extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_box: Area2D = $AttackBox
@onready var hitbox: Area2D = $HitBox
@onready var detection_area: Area2D = $DetectionArea

# Sound effects
@onready var attack_sound: AudioStreamPlayer2D = $AttackSouond
@onready var hit_sound: AudioStreamPlayer2D = $HitSound
@onready var death_sound: AudioStreamPlayer2D = $DeathSounf
@onready var idle_sound: AudioStreamPlayer2D = $IdleSound
@onready var walk_sound: AudioStreamPlayer2D = $WalkSound

@export var attack_cooldown := 1.5
@export var max_health := 100  # Quintupled health compared to knife enemy
@export var move_speed := 80.0  # Slightly slower than knife enemy
@export var attack_damage := 25  # Higher damage

var current_health = max_health
var player = null
var is_attacking = false
var can_attack = true
var is_dead = false
var enraged = false  # For second phase

func _ready():
	# Connect detection area signals
	if detection_area:
		detection_area.connect("body_entered", _on_detection_area_body_entered)
		detection_area.connect("body_exited", _on_detection_area_body_exited)
	
	# Connect hitbox signals
	if hitbox:
		print("✅ HitBox connected.")
		hitbox.connect("area_entered", _on_hitbox_area_entered)
	
	# Start with idle animation
	animated_sprite.play("idle")
	if idle_sound:
		idle_sound.play()
	
	print("🔥 Boss demon ready!")

func _physics_process(_delta):
	if is_dead:
		return
		
	if player:
		# Look at player (optional - might look weird with sprite)
		# look_at(player.global_position)
		
		# Boss faces left or right based on player position
		var direction = (player.global_position - global_position)
		animated_sprite.flip_h = direction.x < 0
		
		if not is_attacking:
			# Move towards player
			velocity = direction.normalized() * move_speed
			animated_sprite.play("walk")
			
			# Play walk sound if not already playing
			if walk_sound and !walk_sound.playing:
				walk_sound.play()
				
			move_and_slide()
		
		# Attack when in range and not on cooldown
		if not is_attacking and can_attack and attack_box.overlaps_body(player):
			print("⚔️ Boss initiating cleave attack...")
			attack()
	else:
		# No player detected
		velocity = Vector2.ZERO
		animated_sprite.play("idle")
		
		# Play idle sound if not already playing
		if idle_sound and !idle_sound.playing:
			idle_sound.play()
		
		# Stop walk sound if it's playing
		if walk_sound and walk_sound.playing:
			walk_sound.stop()
			
		move_and_slide()

func attack():
	is_attacking = true
	can_attack = false
	
	print("🎬 Playing cleave animation")
	animated_sprite.play("cleave")
	
	# Play attack sound
	if attack_sound:
		attack_sound.play()
	
	# Wait for animation to finish
	await animated_sprite.animation_finished
	print("✅ Finished cleave animation.")
	
	# Check if player is still in range after attack animation
	if player and $RangeBox.overlaps_body(player):
		print("💥 Boss deals damage to player!")
		if player.has_method("take_damage"):
			player.take_damage(attack_damage)
	else:
		print("🛡️ Player dodged the attack")
	
	# Return to walking or idle
	if player:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")
	
	is_attacking = false
	
	# Start cooldown timer
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _on_hitbox_area_entered(area):
	print("💥 Boss hit by:", area.name)
	
	# Ignore if boss is already dead or if hit by its own attack box
	if is_dead or area.name.contains("AttackBox"):
		print("🛡️ Ignored damage from AttackBox overlap")
		return
	
	# Take damage (amount would come from the player's weapon)
	take_damage(15)  # Default damage amount

func take_damage(amount: int):
	current_health -= amount
	print("💢 Boss took", amount, "damage! HP =", current_health)
	
	# Play hit animation and sound
	animated_sprite.play("hit")
	if hit_sound:
		hit_sound.play()
	
	# Check for death
	if current_health <= 0:
		die()
	# Check for enraged state (when below 50% health)
	elif current_health <= max_health * 0.5 and !enraged:
		enter_enraged_state()
	
	# Wait for hit animation to finish, then return to previous state
	await animated_sprite.animation_finished
	if !is_dead and player:
		animated_sprite.play("walk")
	elif !is_dead:
		animated_sprite.play("idle")

func enter_enraged_state():
	enraged = true
	print("🔥 Boss entering enraged state!")
	
	# Speed up and increase damage in enraged state
	move_speed *= 1.5
	attack_damage *= 1.3
	attack_cooldown *= 0.7

func die():
	is_dead = true
	print("💀 Boss defeated!")
	
	# Play death animation and sound
	animated_sprite.play("death")
	if death_sound:
		death_sound.play()
	
	# Remove collision to prevent further interactions
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Wait for death animation and sound to finish
	await animated_sprite.animation_finished
	if death_sound:
		await death_sound.finished
	
	# Emit signal before removing (optional - add to class variables if needed)
	# emit_signal("boss_defeated")
	
	# Remove from scene
	queue_free()

func _on_attack_box_body_entered(_body: Node2D) -> void:
	print("📥 Player entered AttackBox (debug log)")

func _on_attack_box_body_exited(_body: Node2D) -> void:
	print("🚪 Player exited the AttackBox (debug log)")

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("👁️ Player entered boss vision range")
		player = body

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player and not attack_box.overlaps_body(body):
		print("🚶‍♂️ Player left boss vision range")
		player = null
