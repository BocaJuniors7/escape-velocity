extends Node2D

@onready var portal := $LevelTransition/Exit
@onready var portal_collision := $"LevelTransition/Exit/Portal Collision"
@onready var portal_sound : AudioStreamPlayer2D = $Sound/PortalSound
@onready var boss_music : AudioStreamPlayer2D = $Sound/BossMusic
@onready var ambient_music : AudioStreamPlayer2D = $"Sound/Ambient Sound"

var enemies_remaining = 0
var boss_music_playing = false
var ambient_music_playing = true

func _ready():
	portal.visible = false
	portal.set_process(false)
	portal_collision.disabled = true

	if ambient_music and not ambient_music.playing:
		ambient_music.play()
		ambient_music_playing = true
		print("🎶 Ambient music started.")

	var enemies = get_tree().get_nodes_in_group("Enemies")
	enemies_remaining = enemies.size()

	for enemy in enemies:
		if not enemy.is_connected("tree_exited", Callable(self, "_on_enemy_defeated")):
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

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not boss_music_playing:
		if ambient_music and ambient_music.playing:
			ambient_music.stop()
			ambient_music_playing = false
			print("🔇 Ambient music stopped.")

		if boss_music:
			boss_music.play()
			boss_music_playing = true
			print("🔥 Boss music started.")
