extends Control

@export var map_2D: _2DGeneration
@export var opening_cutscene: VideoStreamPlayer

@onready var pause: Control = %Pause
@onready var inventory: Control = $Inventory
@onready var settings_menu: Control = $SettingsMenu
@onready var death_message: Control = %DeathMessage
@onready var button_resume: Button = $Pause/Panel/MarginContainer/VBoxContainer/Button_RESUME
@onready var minimap_container: Control = $Minimap
@onready var minimap_viewport: SubViewport = $Minimap/SubViewportContainer/SubViewport
@onready var degug_input = $DebugConsole/MarginContainer/VBoxContainer/Input
@onready var debug_console = $DebugConsole

func _ready() -> void:
	minimap_container.visible = false
	if map_2D != null:
		map_2D.generation_complete.connect(setup_minimap)
	if not opening_cutscene:
		opening_cutscene = VideoStreamPlayer.new()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()
	if event.is_action_pressed("inventory"):
		toggle_inventory()
	if event.is_action_pressed("console"):
		toggle_console()

func setup_minimap():
	map_2D.reparent(minimap_viewport)
	minimap_container.visible = true

func toggle_pause():
	if opening_cutscene.is_playing():
		opening_cutscene.end_cutscene()
		return
	if !pause.visible && !inventory.visible:
		pause.visible = true
		button_resume.grab_focus()
		get_tree().paused = true
	elif inventory.visible:
		toggle_inventory()
	else:
		pause.visible = !pause.visible
		get_tree().paused = false

func toggle_inventory() -> void:
	if pause.visible:
		# Should not show inventory while pause menu is active.
		return
	inventory.visible = !inventory.visible
	get_tree().paused = inventory.visible

func toggle_console() -> void:
	debug_console.visible = not debug_console.visible
	if debug_console.visible:
		degug_input.grab_focus()
		get_tree().paused = true
	else:
		degug_input.release_focus()
		get_tree().paused = false

func resume_pressed() -> void:
	toggle_pause()

func quit_pressed() -> void:
	toggle_pause()
	ChangeScene.to_main_menu()

func show_death() -> void:
	death_message.visible = true

func on_settings_menu_ok_pressed() -> void:
	self.settings_menu.visible = false
	self.pause.visible = true
	button_resume.grab_focus()

func on_button_settings_pressed() -> void:
	self.settings_menu.visible = true
	self.pause.visible = false
	settings_menu.ok_button.grab_focus()
