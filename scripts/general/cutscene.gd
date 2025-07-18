class_name CutScene extends VideoStreamPlayer

signal cut_scene_finished

@export var stop_time: float = -1
@export var parent_control: Control

var time_since_start: float = 0


func _enter_tree() -> void:
	parent_control.visible = false


func _ready():
	finished.connect(end_cutscene)


func _process(delta: float) -> void:
	if stop_time > 0 && is_playing():
		if time_since_start >= stop_time:
			paused = true
			cut_scene_finished.emit()
		time_since_start += delta


func play_cutscene() -> void:
	parent_control.visible = true
	play()
	await get_tree().create_timer(0.5).timeout
	SignalBus.set_player_controls_disabled.emit(true)


func end_cutscene():
	get_tree().paused = false
	stop()
	visible = false
	parent_control.visible = false
	SignalBus.set_player_controls_disabled.emit(false)
	cut_scene_finished.emit()


func go_to_stop_time() -> void:
	stream_position = stop_time
	await get_tree().create_timer(0.5).timeout
	paused = true
	cut_scene_finished.emit()
