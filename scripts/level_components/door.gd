extends Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var door_collider: StaticBody3D = $DoorCollider
@onready var interact_area: Interactable = $InteractArea


var is_opened = false


func _ready() -> void:
	self.interact_area.interacted.connect(self.open_door)


func open_door() -> void:
	if self.is_opened:
		return # Door is already open
	if Game.room_key_count < 1:
		print("Not enough keys to open door.")
		return

	self.is_opened = true
	Game.room_key_count -= 1
	SignalBus.room_key_used.emit()
	self.animation_player.play("open_door")
	self.door_collider.process_mode = Node.PROCESS_MODE_DISABLED
