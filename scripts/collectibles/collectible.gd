class_name Collectible extends Area3D

signal collected


func _ready() -> void:
	self.body_entered.connect(self.on_body_entered)


func on_body_entered(body: Node3D) -> void:
	if body is Player:
		self.collected.emit()
