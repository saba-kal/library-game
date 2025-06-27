class_name Interactable extends Area3D

signal interacted

@export var interact_on_enter: bool = false


func _ready() -> void:
	self.body_entered.connect(self.on_body_entered)
	self.body_exited.connect(self.on_body_exited)


func interact() -> void:
	self.interacted.emit()


func on_body_entered(body: Node3D) -> void:
	if body is Player:
		SignalBus.player_entered_interactable_area.emit(self)


func on_body_exited(body: Node3D) -> void:
	if body is Player:
		SignalBus.player_exited_interactable_area.emit(self)
