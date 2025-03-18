extends CanvasLayer

@onready var battery_bar: ProgressBar = $Control/BatteryBar  # Ensure this path is correct!
@onready var battery_label: Label = $Control/BatteryLabel  # Ensure this path is correct!

func _ready():
	# Debugging - Check if UI elements exist
	if battery_bar == null:
		print("❌ BatteryBar NOT FOUND in HUD! Check scene tree.")
	if battery_label == null:
		print("❌ BatteryLabel NOT FOUND in HUD! Check scene tree.")

# Function to update battery HUD display
func update_battery(level: float, max_level: float):
	if battery_bar == null or battery_label == null:
		print("⚠️ HUD elements not found! Check scene tree.")
		return  # Prevents crashes

	battery_bar.max_value = max_level
	battery_bar.value = level
	battery_label.text = "Battery: " + str(int(level)) + "%"
