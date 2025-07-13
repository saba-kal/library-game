extends Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var door_collider: StaticBody3D = $DoorCollider
@onready var interact_area: Area3D = $InteractArea


var is_opened = false


func _ready() -> void:
	interact_area.body_entered.connect(on_body_entered)


func open_door() -> void:
	if self.is_opened:
		return # Door is already open
	if Game.room_key_count < 1:
		print("Not enough keys to open door.")
		return
	Game.room_key_count -= 1
	SignalBus.room_key_used.emit()
	self.open_door_ignore_keys()


func open_door_ignore_keys() -> void:
	if self.is_opened:
		return # Door is already open
	self.is_opened = true
	self.animation_player.play("open_door")


func on_body_entered(body: Node3D) -> void:
	if body is Player:
		SignalBus.player_entered_boss_door_area.emit()
		if Game.room_key_count >= 1:
			open_door()
