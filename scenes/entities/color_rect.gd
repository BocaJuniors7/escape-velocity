extends ColorRect

var stars = []
var star_colors = [Color(1, 1, 1, 0.8), Color(0.9, 0.9, 1, 0.7), Color(1, 1, 0.9, 0.6)]
var viewport_size = Vector2()

func _ready():
	viewport_size = get_viewport_rect().size
	# Create stars
	for i in range(200):
		var star = {
			"position": Vector2(randf() * viewport_size.x, randf() * viewport_size.y),
			"size": randf() * 2 + 1,
			"color": star_colors[randi() % star_colors.size()],
			"twinkle_speed": randf() * 2 + 1,
			"twinkle_time": randf() * 10  # Random phase
		}
		stars.append(star)

func _process(delta):
	# Update star twinkle
	for star in stars:
		star.twinkle_time += delta * star.twinkle_speed
		# Use sin to create pulsing effect
		var alpha = (sin(star.twinkle_time) + 1) / 2
		star.color.a = 0.3 + (0.7 * alpha)
	
	# Force redraw
	queue_redraw()

func _draw():
	# Draw each star
	for star in stars:
		draw_circle(star.position, star.size, star.color)
