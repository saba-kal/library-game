extends Node

@export var heal_amount: int = 1

@onready var collectible: Collectible = $CollectibleArea

var player: Player


func _ready() -> void:
	self.collectible.collected.connect(self.on_collected)
	SignalBus.player_spawned.connect(self.on_player_spawned)


func on_player_spawned(plr: Player):
	self.player = plr


func on_collected() -> void:
	if self.player:
		self.player.heal(heal_amount)
		self.queue_free()
	else:
		printerr("unexpected null value for player object. Unable to collect health.")
