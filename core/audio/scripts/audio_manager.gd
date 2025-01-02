extends Node

@export var sound_effects: Array[SoundEffect] = []

@onready var music_audio_stream_player: AudioStreamPlayer = $MusicAudioStreamPlayer

var sound_dictionary: Dictionary = {}


func _ready() -> void:
	for sound_effect: SoundEffect in self.sound_effects:
		if self.sound_dictionary.has(sound_effect.name):
			printerr("Sound %s was defined multiple times. Only keeping one instance." % sound_effect.name)
		else:
			self.sound_dictionary[sound_effect.name] = sound_effect
	SignalBus.scene_change_initiated.connect(self.on_scene_change_initiated)


func play(sound_name: String) -> void:
	if !self.sound_dictionary.has(sound_name):
		printerr("Could not find sound %s." % sound_name)
		return
	var sound_effect: SoundEffect = self.sound_dictionary[sound_name]
	var audio_stream_player := AudioStreamPlayer.new()
	audio_stream_player.stream = sound_effect.stream
	audio_stream_player.volume_db = sound_effect.volume_db
	audio_stream_player.pitch_scale = sound_effect.pitch_scale
	audio_stream_player.bus = "SFX"
	self.add_child(audio_stream_player)
	audio_stream_player.play()
	audio_stream_player.finished.connect(audio_stream_player.queue_free)


func play_3d(sound_name: String, position: Vector3) -> void:
	if !self.sound_dictionary.has(sound_name):
		printerr("Could not find sound %s." % sound_name)
		return
	var sound_effect: SoundEffect3D = self.sound_dictionary[sound_name]
	var audio_stream_player := create_audio_stream_player_3d(sound_effect)
	self.add_child(audio_stream_player)
	audio_stream_player.global_position = position
	audio_stream_player.play()
	audio_stream_player.finished.connect(audio_stream_player.queue_free)


func attach_sound_3d(node: Node3D, sound_name: String) -> AudioStreamPlayer3D:
	if !self.sound_dictionary.has(sound_name):
		printerr("Could not find sound %s." % sound_name)
		return null
	var sound_effect: SoundEffect3D = self.sound_dictionary[sound_name]
	var audio_stream_player := create_audio_stream_player_3d(sound_effect)
	node.add_child(audio_stream_player)
	return audio_stream_player


func set_music(music_name: String) -> void:
	self.music_audio_stream_player["parameters/switch_to_clip"] = music_name
	self.music_audio_stream_player.play()


func create_audio_stream_player_3d(sound_effect: SoundEffect3D) -> AudioStreamPlayer3D:
	var audio_stream_player := AudioStreamPlayer3D.new()
	audio_stream_player.stream = sound_effect.stream
	audio_stream_player.attenuation_model = sound_effect.attenuation_model
	audio_stream_player.volume_db = sound_effect.volume_db
	audio_stream_player.unit_size = sound_effect.unit_size
	audio_stream_player.max_db = sound_effect.max_db
	audio_stream_player.pitch_scale = sound_effect.pitch_scale
	audio_stream_player.max_distance = sound_effect.max_distance
	audio_stream_player.bus = "SFX"
	return audio_stream_player


func on_scene_change_initiated():
	#Don't play music while game is loading another scene.
	self.music_audio_stream_player.stop()
