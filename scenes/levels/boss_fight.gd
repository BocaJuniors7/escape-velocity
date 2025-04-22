extends Node2D

@onready var portal := $LevelTransition/Exit
@onready var portal_collision := $"LevelTransition/Exit/Portal Collision"
@onready var portal_sound : AudioStreamPlayer2D = $Sound/PortalSound

var enemies_remaining = 0

func _ready():
	portal.visible = false
	portal.set_process(false)
	portal_collision.disabled = true

	var enemies = get_tree().get_nodes_in_group("Enemies")
	enemies_remaining = enemies.size()

	for enemy in enemies:
		if enemy.is_connected("tree_exited", Callable(self, "_on_enemy_defeated")) == false:
			enemy.connect("tree_exited", Callable(self, "_on_enemy_defeated"))

func _on_enemy_defeated():
	enemies_remaining -= 1
	print("🗡️ Enemies remaining:", enemies_remaining)

	if enemies_remaining <= 0:
		print("✨ ALL enemies defeated! Portal unlocked.")
		portal.visible = true
		portal.set_process(true)
		portal_collision.disabled = false
		
		# 🎵 Play portal sound
		if portal_sound:
			portal_sound.play()
			
var boss_music_playing = false
@onready var boss_music : AudioStreamPlayer2D = $Sound/BossMusic




func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not boss_music_playing:
		boss_music.play()
		boss_music_playing = true
