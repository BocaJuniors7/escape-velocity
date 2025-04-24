extends Node2D

@onready var deaths_label = $CanvasLayer/VBoxContainer/Deaths
@onready var health_lost_label = $CanvasLayer/VBoxContainer/HealthLost
@onready var energy_consumed_label = $CanvasLayer/VBoxContainer/EnergyConstumed
@onready var bullets_fired_label = $CanvasLayer/VBoxContainer/BulletsFired
@onready var exit_button = $CanvasLayer/ExitGame

func _ready():
	# Load stats from GameState and display
	deaths_label.text = "Deaths: " + str(GameState.total_deaths)
	health_lost_label.text = "Health Lost: " + str(GameState.total_health_lost)
	energy_consumed_label.text = "Energy Consumed: " + str(GameState.total_energy_consumed)
	bullets_fired_label.text = "Bullets Fired: " + str(GameState.total_bullets_fired)

	# Connect button
	if exit_button:
		exit_button.connect("pressed", Callable(self, "_on_exit_game_pressed"))

func _on_exit_game_pressed():
	print("🚪 Exiting to Title Screen")
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
