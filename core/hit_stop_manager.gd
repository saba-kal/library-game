extends Node


func frame_freeze(timescale: float, duration: float) -> void:
	Engine.time_scale = timescale
	await get_tree().create_timer(
		duration,
		true, # process_always. Always process even if SceneTree.paused is true
		false, # process_in_physics. We want this timer to updated in the process frame instead of physics.
		true # ignore_timescale. We do not want this timer to slow down because the engine slowed down.
	).timeout
	Engine.time_scale = 1.0
