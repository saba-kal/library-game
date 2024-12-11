extends Area3D
class_name Attack_Area_01
signal player_in_hit_range(player)

@export var attack_width:float = 2
@export var attack_length:float = 1

@onready var attack_shape:CollisionPolygon3D = %CollisionPolygon3D


func _ready() -> void:
	update_attack_size(attack_length, attack_width)

func update_attack_size(length:float, width:float):
	attack_shape.polygon[0].x = length
	attack_shape.polygon[1].x = length
	attack_shape.polygon[0].y = (width / 2) * -1
	attack_shape.polygon[1].y = (width / 2)
