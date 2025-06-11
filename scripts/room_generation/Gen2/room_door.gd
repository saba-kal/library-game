class_name RoomDoor extends Area3D

@onready var player_spawn_point = $PlayerSpawnPoint
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var door_collider: StaticBody3D = $DoorCollider

var connected_room: RoomVariation
var direction: RoomVariation.ROOM_DIRECTION
var is_opened = false

func _ready() -> void:
	self.body_entered.connect(self.on_body_entered)


func on_body_entered(body: Node3D):
	if body is Player:
		if !is_instance_valid(connected_room):
			printerr("Unable tp take player to anothor room because this door is missing a connection.")
			return
		var opposite_door: RoomDoor = connected_room.get_opposite_door(direction)
		if is_instance_valid(opposite_door):
			body.global_position = opposite_door.player_spawn_point.global_position
			SignalBus.player_moved_to_room.emit(connected_room)
		else:
			printerr("Unable to take player to room " + connected_room.name + " because it is missing an opposite door.")

func open_door() -> void:
	if self.is_opened:
		return # Door is already open
	self.is_opened = true
	self.animation_player.play("open_door")
	self.door_collider.process_mode = Node.PROCESS_MODE_DISABLED

func dissappear() -> void:
	self.visible = false
	self.door_collider.process_mode = Node.PROCESS_MODE_DISABLED
