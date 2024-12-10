extends Area3D
class_name ConeDetection
signal player_detected(player)

@export var cone_width:float = 6
@export var cone_length:float = 15

@onready var cone_shape:CollisionPolygon3D = %CollisionPolygon3D


func _ready() -> void:
	update_cone_size()
	
func update_cone_size():
	cone_shape.polygon[0].x = cone_length
	cone_shape.polygon[1].x = cone_length
	cone_shape.polygon[0].y = (cone_width / 2) * -1
	cone_shape.polygon[1].y = (cone_width / 2)
