extends AttachedSound3D

@export var interval_min: float = 2
@export var interval_max: float = 4

var enabled: bool = false
var next_interval: float
var time_since_sound_played: float = 0


func _ready() -> void:
	self.next_interval = randf_range(self.interval_min, self.interval_max)
	super._ready()


func _process(delta: float) -> void:
	if self.time_since_sound_played >= self.next_interval:
		self.audio_stream_player_3d.play()
		self.time_since_sound_played = 0
		self.next_interval = randf_range(self.interval_min, self.interval_max)
	self.time_since_sound_played += delta


func play() -> void:
	self.enabled = true


func stop():
	self.enabled = false
