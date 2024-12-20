extends Control

@onready var pause: Control = %Pause
@onready var inventory: Control = $Inventory
@onready var death_message: Control = %DeathMessage

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()
	if event.is_action_pressed("inventory"):
		toggle_inventory()

func toggle_pause():
	if !pause.visible && !inventory.visible:
		pause.visible = true
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

func resume_pressed() -> void:
	toggle_pause()

func quit_pressed() -> void:
	toggle_pause()
	ChangeScene.to_main_menu()

func show_death() -> void:
	death_message.visible = true
