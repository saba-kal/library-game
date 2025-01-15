class_name DamageFlicker extends Node

@export var mesh_array : Array[MeshInstance3D]
@export var flicker_amount : int = 6

var flicker_original_amount : int = 0
var timer: Timer

func _ready() -> void:
	flicker_original_amount = flicker_amount
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(flicker)
	add_child(timer)

func flicker() -> void:
	flicker_amount -= 1
	if flicker_amount <= 0:
		timer.stop()
		for mesh in mesh_array:
			if is_instance_valid(mesh):
				mesh.visible = true
				flicker_amount = flicker_original_amount
		return
	for mesh in mesh_array:
		if is_instance_valid(mesh):
			mesh.visible = !mesh.visible
	timer.start(0.1)
