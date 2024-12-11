extends Node3D

var room_length: int = 24

var open: Resource = preload("res://scenes/rooms/open_room.tscn")
var three: Resource = preload("res://scenes/rooms/startroom.tscn")
var tunnel_straight: Resource = preload("res://scenes/rooms/tunnel_straight.tscn")
var tunnel_curved: Resource = preload("res://scenes/rooms/tunnel_curved.tscn")
var dead_end: Resource = preload("res://scenes/rooms/dead_end.tscn")


func _ready() -> void:
	add_room(open, 1, 0)
	add_room(tunnel_curved, 1, 1, -1)
	add_room(tunnel_curved, 2, 0, 1)
	add_room(tunnel_curved, 2, 1, 0)
	add_room(dead_end, 1, -1, 1)
	add_room(three, 0, -1, 1)
	add_room(dead_end, 0, -2, 1)
	add_room(dead_end, -1, -1, 2)
	add_room(tunnel_straight, -1, 0)
	add_room(dead_end, -2, 0, 2)


func add_room(room: Resource, x: int = 0, z: int = 0, angle: int = 0) -> void:
	var scene = room.instantiate()
	scene.position.x = x * room_length
	scene.position.z = z * room_length
	scene.rotation.y = angle * PI / 2
	add_child(scene)
