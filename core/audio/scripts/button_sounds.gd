extends Node

@export var button: Button
@export var pressed_sound: String = "ui_button_pressed"
@export var hover_sound: String = "ui_button_hover"


func _ready() -> void:
	self.button.pressed.connect(self.on_button_pressed)
	self.button.focus_entered.connect(self.on_button_hover)
	self.button.mouse_entered.connect(self.on_button_hover)


func on_button_pressed() -> void:
	AudioManager.play(self.pressed_sound)


func on_button_hover() -> void:
	AudioManager.play(self.hover_sound)
