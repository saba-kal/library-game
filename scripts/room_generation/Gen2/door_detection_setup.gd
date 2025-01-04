extends Area3D
class_name DoorDetectionSetup

var door_exit : DoorDetectionSetup
var enterable : bool = true

func _on_area_entered(area: Area3D) -> void:
	door_exit = area
	print("entered and added: " + str(door_exit))

func _on_body_entered(body: Node3D) -> void:
	if (body is Player) and (enterable == true):
		print("Touched with player.")
		door_exit.enterable = false
		body.global_position = door_exit.global_position

func _on_body_exited(body: Node3D) -> void:
	if door_exit != null:
		door_exit.enterable = true
