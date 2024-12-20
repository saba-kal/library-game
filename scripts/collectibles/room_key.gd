extends Node

@onready var collectible: Collectible = $CollectibleArea


func _ready() -> void:
	self.collectible.collected.connect(self.on_collected)


func on_collected() -> void:
	Game.room_key_count += 1
	SignalBus.room_key_collected.emit()
	self.queue_free()
