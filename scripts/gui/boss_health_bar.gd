extends Control

@export var progress_bar: ProgressBar
@export var boss_name_label: Label

var health: Health


func _ready() -> void:
	self.visible = false
	SignalBus.player_entered_boss_room.connect(on_player_entered_boss_room)


func on_player_entered_boss_room(boss: Boss):
	self.visible = true
	health = boss.health
	progress_bar.max_value = health.maximum
	progress_bar.value = health.current
	health.changed.connect(on_health_changed)
	boss_name_label.text = boss.boss_name


func on_player_exited_boss_room(boss: Boss):
	self.visible = false
	health.changed.disconnect(on_health_changed)


func on_health_changed(health:int, _damage_amount:int, _damage_sender:CharacterBody3D):
	progress_bar.value = health
