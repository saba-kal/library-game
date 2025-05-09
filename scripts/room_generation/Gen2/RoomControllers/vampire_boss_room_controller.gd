extends RoomController

@export var animation_player: AnimationPlayer
@export var boss: VampireBoss
@export var path_follow: PathFollow3D
@export var entrance_delay: float = 2.0

var is_enter_animation_playing: bool = false


func _ready() -> void:
	animation_player.animation_finished.connect(on_animation_finished)


func on_player_enter() -> void:
	boss.reset_boss()
	await get_tree().create_timer(entrance_delay).timeout
	boss.start_boss_fight()
	animation_player.play("boss_enter")
	is_enter_animation_playing = true
	SignalBus.player_entered_boss_room.emit(self.boss)


func on_player_exit() -> void:
	boss.reset_boss()
	SignalBus.player_exited_boss_room.emit(self.boss)


func on_animation_finished(anim_name: String) -> void:
	if anim_name == "boss_enter":
		is_enter_animation_playing = false
