extends VideoStreamPlayer

func _ready():
	play()
	finished.connect(end_cutscene)
	get_tree().paused = true

func end_cutscene():
	get_tree().paused = false
	stop()
	visible = false
