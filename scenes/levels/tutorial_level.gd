extends Node2D

@onready var portal := $MapDesign/PortalToNextLevel
@onready var portal_collision := $"MapDesign/PortalToNextLevel/Portal Collision"
@onready var portal_sound : AudioStreamPlayer2D = $"Sounds/Portal Sound effect"

var enemies_remaining = 0

func _ready():
	portal.visible = false
	portal.set_process(false)
	portal_collision.disabled = true

	var enemies = get_tree().get_nodes_in_group("Enemies")
	enemies_remaining = enemies.size()

	for enemy in enemies:
		enemy.connect("tree_exited", Callable(self, "_on_enemy_defeated"))

func _on_enemy_defeated():
	enemies_remaining -= 1
	print("🗡️ Enemies remaining:", enemies_remaining)

	if enemies_remaining <= 0:
		print("✨ ALL enemies defeated! Portal unlocked.")
		portal.visible = true
		portal.set_process(true)
		portal_collision.disabled = false
		
		if portal_sound:
			portal_sound.play()
