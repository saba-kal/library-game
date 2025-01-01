class_name SoundEffect extends Resource

@export var name: String
@export var stream: AudioStream
@export_range(-80, 80) var volume_db: float = 0
@export_range(0.01, 4) var pitch_scale: float = 1
