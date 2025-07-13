extends Node

@export var initial_button: Button
@export var nav_menu: Control
@export var credits_menu: Control
@export var settings_menu: Control
@export var debug_buttons: Control
@onready var settings_button: Button = %Button_SETTINGS
@onready var credits_button: Button = %Button_CREDITS
@onready var credits_ok_button: Button = %CreditsOkButton

func _enter_tree() -> void:
	debug_buttons.visible = OS.is_debug_build()

func _ready() -> void:
	initial_button.grab_focus()
	self.settings_menu.visible = false
	self.nav_menu.visible = true

func play_pressed() -> void:
	print("Pressed Play Button")
	Game.reset_data()
	ChangeScene.to_game_start()

func credits_pressed() -> void:
	credits_menu.visible = true
	nav_menu.visible = false
	credits_ok_button.grab_focus()

func credits_ok_pressed() -> void:
	credits_menu.visible = false
	nav_menu.visible = true
	credits_button.grab_focus()

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
	self.settings_button.grab_focus()

func on_button_settings_pressed() -> void:
	self.settings_menu.visible = true
	self.nav_menu.visible = false
	settings_menu.ok_button.grab_focus()
