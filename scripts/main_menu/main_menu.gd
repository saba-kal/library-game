extends Node

@export var initial_button: Button
@export var nav_menu: Control
@export var settings_menu: Control

func _ready() -> void:
	initial_button.grab_focus()
	self.settings_menu.visible = false
	self.nav_menu.visible = true

func play_pressed() -> void:
	print("Pressed Play Button")

func exit_pressed() -> void:
	print("Pressed Exit Button")
	get_tree().quit()

func debug_pressed() -> void:
	print("Pressed Debug Button")
	ChangeScene.to_debug_area()

func debug_generation_pressed():
	print("Pressed Debug Generation Button")
	ChangeScene.to_debug_generation_area()

func generation_area_two_pressed():
	print("Pressed Debug Generation Button")
	ChangeScene.to_generation_area_two()

func on_settings_menu_ok_pressed() -> void:
	self.settings_menu.visible = false
	self.nav_menu.visible = true

func on_button_settings_pressed() -> void:
	self.settings_menu.visible = true
	self.nav_menu.visible = false
