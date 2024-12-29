extends Node

@export var music_name: String


func _ready() -> void:
	AudioManager.set_music(self.music_name)
