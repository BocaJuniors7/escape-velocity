extends StaticBody2D  

@onready var light: Light2D = $PointLight2D
@export var strobe_speed := 4.0     # Speed of strobe
@export var min_energy := 0.2       # Dimmest point
@export var max_energy := 1.0       # Brightest point

var time := 0.0

func _process(delta):
	time += delta
	# Use sin wave to oscillate energy smoothly
	var strobe = (sin(time * strobe_speed) + 1.0) * 0.5  # Normalize to 0..1
	light.energy = lerp(min_energy, max_energy, strobe)
