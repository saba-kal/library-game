extends Node3D

var room_length: int = 25


@onready var room_chooser = $RoomChooser
var explorecount: int = 0
var explored: Array[Point] = []
var head: QueuedPoint
var tail: QueuedPoint
var zone: int = 0

func _ready() -> void:
    randomize()
    explored.append(Point.new(0, 0))
    enqueue(Point.new(-1, 0, 0, RoomConnector.DIRECTION.LEFT))
    while not is_empty_queue():
        room_cycle(dequeue())
    enqueue(Point.new(0, -1, 0, RoomConnector.DIRECTION.UP))
    zone += 1
    while not is_empty_queue():
        room_cycle(dequeue())
    enqueue(Point.new(1, 0, 0, RoomConnector.DIRECTION.RIGHT))
    zone += 1
    while not is_empty_queue():
        room_cycle(dequeue())

func room_cycle(point: Point) -> void:
    if(is_explored(point)):
        return
    var room: Room = room_chooser.choose_room(point.depth, zone)
    if(not room):
        return
    add_room(room, point.x, point.y, point.direction)
    var connectors = room.get_connectors()
    for connector in connectors:
        var newPoint: Point
        var x = point.x
        var y = point.y
        match  connector.direction:
            RoomConnector.DIRECTION.UP:
                y -= 1
            RoomConnector.DIRECTION.DOWN:
                y += 1
            RoomConnector.DIRECTION.LEFT:
                x -= 1
            RoomConnector.DIRECTION.RIGHT:
                x += 1

        newPoint = Point.new(x, y, point.depth + 1, connector.direction)
        enqueue(newPoint)
    explored.append(point)

func add_room(scene: Room, x: int = 0, z: int = 0, angle: int = 0) -> void:
    scene.position.x = x * room_length
    scene.position.z = z * room_length
    scene.rotate_room(angle)
    add_child(scene)

func is_explored(point: Point) -> bool:
    return explored.any(func(p): return point._equals(p))

func enqueue(point: Point):
    var newnode: QueuedPoint = QueuedPoint.new(point, tail)
    if(head == null):
        head = newnode
        tail = newnode
    else:
        tail.next = newnode
        tail = newnode

func dequeue() -> Point:
    var point: Point = head.point
    head = head.next
    return point

func is_empty_queue() -> bool:
    return head == null

class Point:
    var x: int
    var y: int
    var depth: int
    var direction: RoomConnector.DIRECTION

    func _init(i: int, j: int, d: int = 0, dir = 0) -> void:
        x = i
        y = j
        depth = d
        direction = dir as RoomConnector.DIRECTION

    func _equals(point: Point) -> bool:
        return point and x == point.x and y == point.y

class QueuedPoint:
    var point: Point
    var next: QueuedPoint
    var prev: QueuedPoint

    func _init(newpoint: Point, newprev: QueuedPoint) -> void:
        point = newpoint
        prev = newprev
