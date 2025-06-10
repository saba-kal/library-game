class_name NearbyEnemyTracker extends Area3D

var nearby_enemies: Array[Node3D]


func _ready() -> void:
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)


func on_body_entered(body: Node3D) -> void:
	nearby_enemies.append(body)


func on_body_exited(body: Node3D) -> void:
	nearby_enemies.erase(body)


func get_living_enemies() -> Array[Node3D]:
	var enemies: Array[Node3D] = []
	for node in nearby_enemies:
		if is_instance_valid(node):
			var health: Health = Util.get_child_node_of_type(node, Health)
			if is_instance_valid(health) && health.current > 0:
				enemies.append(node)
	return enemies