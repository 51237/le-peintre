extends Control
@onready var first_level = preload("res://scenes/game.tscn")

func _on_startbtn_button_down() -> void:
	get_tree().change_scene_to_packed(first_level)


func _on_quitbtn_button_down() -> void:
	get_tree().quit()
