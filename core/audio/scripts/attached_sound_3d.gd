class_name AttachedSound3D extends Node3D

@export var sound_name: String
@export var play_on_ready: bool = false

@onready var audio_stream_player_3d: AudioStreamPlayer3D = AudioManager.attach_sound_3d(self, self.sound_name)


func _ready() -> void:
	if self.play_on_ready:
		self.play()


func play() -> void:
	if is_instance_valid(audio_stream_player_3d):
		audio_stream_player_3d.play()

func stop():
	if is_instance_valid(audio_stream_player_3d):
		audio_stream_player_3d.stop()
