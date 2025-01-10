extends Area3D

@export_enum("hub", "haunted_floor") var transition_to: String = "hub"


func _ready() -> void:
	self.body_entered.connect(self.on_body_entered)


func on_body_entered(body: Node3D) -> void:
	if body is Player:
		ChangeScene.to_scene(self.transition_to)
