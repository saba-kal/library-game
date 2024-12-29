class_name SoundEffect3D extends SoundEffect

@export var attenuation_model: AudioStreamPlayer3D.AttenuationModel = AudioStreamPlayer3D.AttenuationModel.ATTENUATION_INVERSE_DISTANCE
@export_range(0.1, 100) var unit_size: float = 10
@export_range(0, 4096) var max_distance: float = 0
@export_range(-24, 6) var max_db: float = 3
