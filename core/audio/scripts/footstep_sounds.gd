class_name FootstepSounds extends Node3D

@export var sound_name: String
@export_range(0.01, 5) var interval: float = 0.5
@export_range(0, 4) var pitch_randomness: float = 0

var audio_stream: AudioStreamPlayer3D
var time_since_last_play: float = 0
var enabled: bool = false
var original_pitch_scale: float


func _ready() -> void:
	self.audio_stream = AudioManager.attach_sound_3d(self, self.sound_name)
	self.original_pitch_scale = self.audio_stream.pitch_scale


func _process(delta: float) -> void:
	if self.time_since_last_play >= self.interval && enabled:
		self.audio_stream.pitch_scale = self.original_pitch_scale + randf_range(-self.pitch_randomness, self.pitch_randomness)
		self.audio_stream.play()
		self.time_since_last_play = 0
	else:
		self.time_since_last_play += delta
