extends Area3D

@export var transition_to: PackedScene


func _ready() -> void:
	self.body_entered.connect(self.on_body_entered)


func on_body_entered(body: Node3D) -> void:
	if body is Player:
		ChangeScene.to_scene(self.transition_to)
