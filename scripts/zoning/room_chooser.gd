class_name RoomChooser extends Node


var open: Resource = preload("res://scenes/rooms/open_room.tscn")
var open_room: Node = open.instantiate()
var three: Resource = preload("res://scenes/rooms/startroom.tscn")
var tunnel_straight: Resource = preload("res://scenes/rooms/tunnel_straight.tscn")
var tunnel_curved: Resource = preload("res://scenes/rooms/tunnel_curved.tscn")
var dead_end: Resource = preload("res://scenes/rooms/dead_end.tscn")
var dead_end_room: Node = dead_end.instantiate()

var rooms = [open, dead_end]

func choose_room(depth: int) -> Room:
    var chances = PackedFloat32Array()
    chances.append(open_room.generation_chance(depth))
    chances.append(dead_end_room.generation_chance(depth))
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
    return rooms[roomindex].instantiate()
