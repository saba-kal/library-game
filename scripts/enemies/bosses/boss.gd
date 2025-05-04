class_name Boss extends CharacterBody3D

signal death

@export var boss_name: String
@export var reward_on_death: PackedScene

@onready var health: Health = $Health


func _ready() -> void:
	health.changed.connect(on_health_changed)


func on_health_changed(_health:int, _delta:int, damage_sender:CharacterBody3D) -> void:
	if health.current <= 0:
		if reward_on_death != null:
			var reward_instance: Node3D = reward_on_death.instantiate()
			get_tree().root.add_child(reward_instance)
			reward_instance.global_position = global_position
		death.emit()
		self.queue_free()
