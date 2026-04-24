extends Control

@onready var first_level = preload("res://scenes/game.tscn")
@onready var fade_overlay = %FadeOverlay
@onready var StatusDot = %StatusDot
@onready var StatusLabel = %StatusLabel
@onready var StartButton = %StartButton

func _ready() -> void:
	ArduinoManager.arduino_connected.connect(_on_arduino_connected)
	ArduinoManager.arduino_disconnected.connect(_on_arduino_disconnected)
	StatusDot.modulate = Color.RED
	StatusLabel.text = "Manette non connectée"
	StartButton.disabled = false

func _on_arduino_connected() -> void:
	StatusDot.modulate = Color.GREEN
	StatusLabel.text = "Manette connectée"
	StartButton.disabled = false

func _on_arduino_disconnected() -> void:
	StatusDot.modulate = Color.RED
	StatusLabel.text = "Déconnectée"
	StartButton.disabled = true

func _on_startbtn_button_down() -> void:
	fade_overlay.modulate.a = 1
	get_tree().change_scene_to_packed(first_level)

func _on_quitbtn_button_down() -> void:
	get_tree().quit()
