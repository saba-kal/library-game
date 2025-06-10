class_name SlashEffect extends Node


@onready var anim_player: AnimationPlayer = $AnimationPlayer


func play() -> void:
	anim_player.play("slash")