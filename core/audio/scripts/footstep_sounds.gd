class_name FootstepSounds extends AttachedSound3D

@export_range(0, 2, 0.1) var pitch_randomness: float = 0

func _ready() -> void:
	super._ready()

func _process(delta: float) -> void:
	pass

func play() -> void:
	if is_instance_valid(audio_stream_player_3d):
		audio_stream_player_3d.pitch_scale += randf_range(-pitch_randomness, pitch_randomness) * .1
		super.play()
		audio_stream_player_3d.pitch_scale = 1.0

func stop():
	pass
