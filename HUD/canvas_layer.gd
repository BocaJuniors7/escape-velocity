extends CanvasLayer

@onready var battery_bar: TextureProgressBar = $Control/BatteryBar
@onready var battery_label: Label = $Control/BatteryLabel
@onready var health_bar: TextureProgressBar = $Control/HealthBar
@onready var health_label: Label = $Control/HealthLabel
@onready var bullet_label: Label = $Control/BulletLabel  # Confirm path is correct

func _ready():
	if bullet_label:
		bullet_label.text = "Ammo: 10 / 10"
		print("🔫 BulletLabel loaded and set: ", bullet_label.text)
	else:
		print("❌ BulletLabel is null!")

	if battery_bar == null:
		print("❌ BatteryBar NOT FOUND!")
	if battery_label == null:
		print("❌ BatteryLabel NOT FOUND!")
	if health_bar == null:
		print("❌ HealthBar NOT FOUND!")
	if health_label == null:
		print("❌ HealthLabel NOT FOUND!")

func update_ammo(current: int, max: int):
	if bullet_label:
		bullet_label.text = "Ammo: " + str(current) + " / " + str(max)
		print("🔫 Ammo Updated: ", bullet_label.text)
	else:
		print("❌ BulletLabel is null when trying to update ammo!")

func update_battery(level: float, max_level: float):
	if battery_bar and battery_label:
		battery_bar.max_value = max_level
		battery_bar.value = level
		battery_label.text = "Battery: " + str(int(level)) + "%"
	else:
		print("⚠️ Battery UI missing!")

func update_health(current: int, max: int):
	if health_bar and health_label:
		health_bar.max_value = max
		health_bar.value = current
		health_label.text = "Health: " + str(current)
	else:
		print("⚠️ Health UI missing!")
