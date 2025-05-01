class_name VampireBoss extends CharacterBody3D

signal death

@export var reward_on_death: PackedScene

@onready var health: Health = $Health


func _ready() -> void:
	self.health.changed.connect(self.on_health_changed)


func on_health_changed(_health:int, _delta:int, damage_sender:CharacterBody3D) -> void:
	if self.health.current <= 0:
		if self.reward_on_death != null:
			var reward_instance: Node3D = self.reward_on_death.instantiate()
			get_tree().root.add_child(reward_instance)
			reward_instance.global_position = self.global_position
		self.death.emit()
		self.queue_free()
