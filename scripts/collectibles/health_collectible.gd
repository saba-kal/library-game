extends Node

@export var heal_amount: int = 1

@onready var collectible: Collectible = $CollectibleArea

var player: Player


func _ready() -> void:
	self.collectible.collected.connect(self.on_collected)
	self.player = self.get_tree().get_first_node_in_group("player")


func on_collected() -> void:
	self.player.heal(heal_amount)
	self.queue_free()
