class_name FootstepSounds extends AttachedSound3D

@export_range(0, 2, 0.1) var pitch_randomness: float = 0

var original_pitch_scale: float


func _ready() -> void:
	super._ready()
	original_pitch_scale = audio_stream_player_3d.pitch_scale

func _process(delta: float) -> void:
	pass

func play() -> void:
	audio_stream_player_3d.pitch_scale += randf_range(-pitch_randomness, pitch_randomness) * .1
	super.play()
	audio_stream_player_3d.pitch_scale = original_pitch_scale

func stop():
	pass
