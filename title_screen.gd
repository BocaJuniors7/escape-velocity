extends Node2D

@export var tutorial_scene_path: String = "res://scenes/levels/tutorial_level.tscn"

func _ready():
	$CanvasLayer/FadeRect.modulate.a = 0.0

func _unhandled_input(event):
	
	if event.is_action_pressed("start"):
		$AnimationPlayer.play("fade_out")

func goto_tutorial():
	get_tree().change_scene_to_file(tutorial_scene_path)
