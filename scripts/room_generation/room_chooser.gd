class_name RoomChooser extends Node


var open: Resource = preload("res://scenes/room_generation/open_room.tscn")
var open_room: Node = open.instantiate()
var three: Resource = preload("res://scenes/room_generation/startroom.tscn")
var tunnel_straight: Resource = preload("res://scenes/room_generation/tunnel_straight.tscn")
var tunnel_curved: Resource = preload("res://scenes/room_generation/tunnel_curved.tscn")
var dead_end: Resource = preload("res://scenes/room_generation/dead_end.tscn")
var dead_end_room: Node = dead_end.instantiate()

@export var zone_1: Array[PackedScene]
@export var zone_2: Array[PackedScene]
@export var zone_3: Array[PackedScene]
@onready var zones = [zone_1, zone_2, zone_3]
var zone_1_rooms
var zone_2_rooms
var zone_3_rooms
var zones_rooms

func _ready() -> void:
	zone_1_rooms = zone_1.map(func(scene: PackedScene): return scene.instantiate())
	zone_2_rooms = zone_2.map(func(scene): return scene.instantiate())
	zone_3_rooms = zone_3.map(func(scene): return scene.instantiate())
	zones_rooms = [zone_1_rooms, zone_2_rooms, zone_3_rooms]

func choose_room(depth: int, zone_index: int) -> Room:
	var zone = zones[zone_index]
	var zone_rooms = zones_rooms[zone_index]
	var chances = zone_rooms.map(func (room): return room.generation_chance(depth))
	var chance_count: float = 0
	for c in chances:
		chance_count += c
	if(chance_count == 0):
		return null
	var chance_float: float = 0
	var wheightedchances = PackedFloat32Array()
	for c: float in chances:
		chance_float += c / chance_count
		wheightedchances.append(chance_float)
	var randomfloat = randf()
	var roomindex: int = wheightedchances.bsearch(randomfloat)
	return zone[roomindex].instantiate()
