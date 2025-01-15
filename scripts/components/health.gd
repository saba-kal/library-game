class_name Health extends Node

@export var maximum:int = 3

var current:int
var health_owner

signal changed(health:int, damage_amount:int, damage_sender:CharacterBody3D)

func _ready() -> void:
	health_owner = get_parent()
	current = maximum
	owner.set_meta("damageable", true)


func take_damage(damage_amount:int, damage_sender:CharacterBody3D = null) -> void:
	var overkill = maxi(damage_amount - current, 0)
	damage_amount = mini(damage_amount, current)
	if damage_amount <= 0: return
	current -= damage_amount
	changed.emit(current, damage_amount, damage_sender)


func heal(heal_amount: int) -> void:
	current = clamp(self.current + heal_amount, 0, self.maximum)
	self.changed.emit(self.current, heal_amount)
