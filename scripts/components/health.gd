extends Node

@export var maximum:int = 3

var current:int

signal changed(health:int, delta:int)

func _ready() -> void:
	current = maximum
	owner.set_meta("damageable", true)

func take_damage(damage_amount:int) -> void:
	var overkill = maxi(damage_amount - current, 0)
	damage_amount = mini(damage_amount, current)
	if damage_amount <= 0: return
	current -= damage_amount
	changed.emit(current, -damage_amount)
