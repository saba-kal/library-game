extends Node


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
