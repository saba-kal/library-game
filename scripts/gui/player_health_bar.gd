extends Control

@export var images_container: Control
@export var single_health_icon: PackedScene


var current_health: int 
var max_health: int
var player_health: Health


func _ready() -> void:
	var player: Player = self.get_tree().get_first_node_in_group("player")
	self.player_health = Util.get_child_node_of_type(player, Health)
	if self.player_health == null:
		printerr("Player character is missing health component")
		return
	self.player_health.changed.connect(self.update_health)
	await get_tree().process_frame
	self.init_health(self.player_health.current, self.player_health.maximum)


func init_health(current_hp: int, max_hp: int) -> void:
	self.current_health = current_hp
	self.max_health = max_hp
	for child: Node in self.images_container.get_children():
		child.queue_free()
	for i: int in range(0, clamp(self.current_health, 0, self.max_health)):
		var health_icon: Node = self.single_health_icon.instantiate()
		self.images_container.add_child(health_icon)


func update_health(_health: int, health_delta: int) -> void:
	self.current_health += health_delta
	var clamped_health: int = clamp(self.current_health, 0, self.max_health)

	for i in range(0, clamped_health):
		var child: Control = self.images_container.get_child(i)
		child.visible = true

	for i in range(clamped_health, self.max_health):
		var child: Control = self.images_container.get_child(i)
		child.visible = false
