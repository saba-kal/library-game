extends Node

@export var sound_effects: Array[SoundEffect] = []

var sound_dictionary: Dictionary = {}


func _ready() -> void:
	for sound_effect: SoundEffect in self.sound_effects:
		if self.sound_dictionary.has(sound_effect.name):
			printerr("Sound %s was defined multiple times. Only keeping one instance." % sound_effect.name)
		else:
			self.sound_dictionary[sound_effect.name] = sound_effect


func play(sound_name: String) -> void:
	if !self.sound_dictionary.has(sound_name):
		printerr("Could not find sound." % sound_name)
		return
	var sound_effect: SoundEffect = self.sound_dictionary[sound_name]
	var audio_stream_player := AudioStreamPlayer.new()
	audio_stream_player.stream = sound_effect.stream
	audio_stream_player.volume_db = sound_effect.volume_db
	audio_stream_player.pitch_scale = sound_effect.pitch_scale
	self.add_child(audio_stream_player)
	audio_stream_player.play()
	audio_stream_player.finished.connect(audio_stream_player.queue_free)


func play_3d(sound_name: String, position: Vector3) -> void:
	if !self.sound_dictionary.has(sound_name):
		printerr("Could not find sound." % sound_name)
		return
	var sound_effect: SoundEffect3D = self.sound_dictionary[sound_name]
	var audio_stream_player := AudioStreamPlayer3D.new()
	audio_stream_player.stream = sound_effect.stream
	audio_stream_player.attenuation_model = sound_effect.attenuation_model
	audio_stream_player.volume_db = sound_effect.volume_db
	audio_stream_player.unit_size = sound_effect.unit_size
	audio_stream_player.max_db = sound_effect.max_db
	audio_stream_player.pitch_scale = sound_effect.pitch_scale
	audio_stream_player.max_distance = sound_effect.max_distance
	self.add_child(audio_stream_player)
	audio_stream_player.global_position = position
	audio_stream_player.play()
	audio_stream_player.finished.connect(audio_stream_player.queue_free)
