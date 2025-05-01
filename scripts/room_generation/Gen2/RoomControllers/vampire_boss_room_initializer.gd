extends RoomController

@export var animation_player: AnimationPlayer
@export var boss: VampireBoss
@export var path_follow: PathFollow3D

var is_enter_animation_playing: bool = false


func _ready() -> void:
	self.animation_player.animation_finished.connect(self.on_animation_finished)


func _process(delta: float) -> void:
	if self.is_enter_animation_playing:
		self.boss.global_position = self.path_follow.global_position


func initialize_on_player_enter() -> void:
	self.boss.global_position = Vector3.ZERO
	self.animation_player.play("boss_enter")
	self.is_enter_animation_playing = true


func on_animation_finished(anim_name: String) -> void:
	if anim_name == "boss_enter":
		self.is_enter_animation_playing = false
