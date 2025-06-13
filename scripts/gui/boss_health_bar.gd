extends Control

@export var progress_bar: ProgressBar
@export var boss_name_label: Label
@export var main_color: Color
@export var disabled_color: Color

var health: Health


func _ready() -> void:
	self.visible = false
	SignalBus.player_entered_boss_room.connect(on_player_entered_boss_room)
	SignalBus.player_exited_boss_room.connect(on_player_exited_boss_room)
	progress_bar.add_theme_stylebox_override("fill", progress_bar.get_theme_stylebox("fill").duplicate())


func on_player_entered_boss_room(boss: Boss):
	self.visible = true
	health = boss.health
	progress_bar.max_value = health.maximum
	progress_bar.value = health.current
	on_health_immunity_changed(health.is_immune)
	health.changed.connect(on_health_changed)
	health.immunity_changed.connect(on_health_immunity_changed)
	boss_name_label.text = boss.boss_name


func on_player_exited_boss_room(_boss: Boss):
	self.visible = false
	health.changed.disconnect(on_health_changed)
	health.immunity_changed.disconnect(on_health_immunity_changed)


func on_health_changed(new_health: int, _damage_amount: int, _damage_sender: CharacterBody3D):
	progress_bar.value = new_health


func on_health_immunity_changed(is_immune: bool):
	if is_immune:
		progress_bar.get("theme_override_styles/fill").bg_color = disabled_color
	else:
		progress_bar.get("theme_override_styles/fill").bg_color = main_color
