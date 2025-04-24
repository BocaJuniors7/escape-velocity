extends Node2D


@onready var start_button: Button = $CanvasLayer/Start
@onready var exit_button: Button = $CanvasLayer/Exit

# Set the path to your first level here
@export_file("*.tscn") var first_level_path: String = "res://scenes/tutorial_level.tscn"

func _ready():
	# Connect button signals
	start_button.pressed.connect(_on_start_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _on_start_pressed():
	print("🚀 Starting game...")
	get_tree().change_scene_to_file(first_level_path)

func _on_exit_pressed():
	print("👋 Exiting game...")
	get_tree().quit()
