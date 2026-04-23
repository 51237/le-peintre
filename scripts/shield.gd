extends Node2D

@onready var visual = $ShieldVisual

func _ready():
	visible = false

func show_shield(color: Color):
	color.a = 0.3
	visual.set_color(color)  # ← set_color au lieu de .color
	visible = true

func flash_and_hide():
	visual.set_color(Color(1, 1, 1, 0.8))
	await get_tree().create_timer(0.1).timeout
	visual.set_color(Color(1, 1, 1, 0.3))
	await get_tree().create_timer(0.05).timeout
	visible = false
