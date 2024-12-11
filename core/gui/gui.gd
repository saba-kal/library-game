extends Control

@onready var pause: Control = %Pause

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause():
	if ChangeScene.current_scene != ChangeScene.main_menu:
		if !pause.visible:
			pause.visible = !pause.visible
			get_tree().paused = true
		else:
			pause.visible = !pause.visible
			get_tree().paused = false

func resume_pressed() -> void:
	toggle_pause()

func quit_pressed() -> void:
	toggle_pause()
	ChangeScene.to_main_menu()
