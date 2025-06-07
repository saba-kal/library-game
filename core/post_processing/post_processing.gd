extends Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func play_player_hurt_effect() -> void:
	if animation_player.is_playing():
		animation_player.stop()
	animation_player.play("player_hurt")


func _process(_delta: float) -> void:
	animation_player.speed_scale = 1.0 / Engine.time_scale