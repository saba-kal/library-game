extends Node

@export var health: Health

@onready var progress_bar: ProgressBar = $SubViewport/HealthProgressBar


func _ready() -> void:
	self.progress_bar.max_value = self.health.maximum
	self.progress_bar.value = self.health.current
	self.health.changed.connect(self.on_health_changed)


func on_health_changed(health: int, _delta: int) -> void:
	self.progress_bar.value = health
