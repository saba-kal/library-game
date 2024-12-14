class_name Room extends Node3D

func get_connectors() -> Array[RoomConnector]:
    var nodes: Array[RoomConnector] = []
    for child in get_children():
        if child is RoomConnector:
            nodes.append(child)
    return nodes

func generation_chance(_depth: int) -> float:
    return 0

func random_connector() -> RoomConnector:
    var connectors = get_connectors()
    return connectors[randi() % connectors.size()]

func rotate_room(direction):
    direction += random_connector().direction
    rotate_y(direction * PI / 2)
    for connector in get_connectors():
        connector.direction += direction
        connector.direction %= 4
