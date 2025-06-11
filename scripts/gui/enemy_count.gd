extends Label

func _ready():
	SignalBus.enemy_quantity_changed.connect(on_change_enemy_count)

func on_change_enemy_count(living: int,total: int):
	text = "Enemies: "+str(living)+" / "+str(total)
