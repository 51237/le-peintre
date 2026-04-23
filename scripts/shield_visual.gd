extends Node2D

var shield_color = Color(1, 0, 0, 0.3)
var radius = 150.0

func set_color(c: Color):
	shield_color = c
	queue_redraw()

func _draw():
	draw_circle(Vector2.ZERO, radius, shield_color)
