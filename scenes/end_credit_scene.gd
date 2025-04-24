extends Node2D

@onready var play_again_button: Button = $CanvasLayer/PlayAgain
@onready var exit_button: Button = $CanvasLayer/Exit

func _ready():
	play_again_button.connect("pressed", Callable(self, "_on_play_again_pressed"))
	exit_button.connect("pressed", Callable(self, "_on_exit_pressed"))

func _on_play_again_pressed():
	if GameState.last_level_scene != "":
		print("🔄 Reloading Last Level:", GameState.last_level_scene)
		get_tree().change_scene_to_file(GameState.last_level_scene)
	else:
		print("❌ No last level scene recorded!")



func _on_exit_pressed():
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")  # Change to your Main Menu scene
