extends CanvasLayer

@onready var battery_bar: ProgressBar = $Control/BatteryBar
@onready var battery_label: Label = $Control/BatteryLabel
@onready var health_bar: ProgressBar = $Control/HealthBar
@onready var health_label: Label = $Control/HealthLabel

func _ready():
	if battery_bar == null:
		print("❌ BatteryBar NOT FOUND in HUD! Check scene tree.")
	if battery_label == null:
		print("❌ BatteryLabel NOT FOUND in HUD! Check scene tree.")
	if health_bar == null:
		print("❌ HealthBar NOT FOUND in HUD! Check scene tree.")
	if health_label == null:
		print("❌ HealthLabel NOT FOUND in HUD! Check scene tree.")

func update_battery(level: float, max_level: float):
	if battery_bar == null or battery_label == null:
		print("⚠️ HUD elements not found! Check scene tree.")
		return

	battery_bar.max_value = max_level
	battery_bar.value = level
	battery_label.text = "Battery: " + str(int(level)) + "%"

func update_health(current: int, max: int):
	if health_bar == null or health_label == null:
		print("⚠️ Health UI elements not found!")
		return

	health_bar.max_value = max
	health_bar.value = current
	health_label.text = "Health: " + str(current) + "/" + str(max)
