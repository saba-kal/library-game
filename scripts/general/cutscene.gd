extends VideoStreamPlayer

@export var cutscene_background: Control

func _enter_tree() -> void:
	cutscene_background.visible = true

func _ready():
	play()
	finished.connect(end_cutscene)
	get_tree().paused = true

func end_cutscene():
	get_tree().paused = false
	stop()
	visible = false
	cutscene_background.visible = false
