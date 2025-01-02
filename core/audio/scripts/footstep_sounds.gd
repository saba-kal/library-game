class_name FootstepSounds extends AttachedSound3D

@export_range(0.01, 5) var interval: float = 0.5
@export_range(0, 4) var pitch_randomness: float = 0

var time_since_last_play: float = 0
var enabled: bool = false
var original_pitch_scale: float


func _ready() -> void:
	super._ready()
	self.original_pitch_scale = self.audio_stream_player_3d.pitch_scale


func _process(delta: float) -> void:
	if self.time_since_last_play >= self.interval && enabled:
		self.audio_stream_player_3d.pitch_scale = self.original_pitch_scale + randf_range(-self.pitch_randomness, self.pitch_randomness)
		self.audio_stream_player_3d.play()
		self.time_since_last_play = 0
	else:
		self.time_since_last_play += delta


func play() -> void:
	self.enabled = true


func stop():
	self.enabled = false
