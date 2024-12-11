extends Node


func play_pressed() -> void:
	print("Pressed Play Button")

func exit_pressed() -> void:
	print("Pressed Exit Button")
	get_tree().quit()

func debug_pressed() -> void:
	print("Pressed Debug Button")
	ChangeScene.to_debug_area()
