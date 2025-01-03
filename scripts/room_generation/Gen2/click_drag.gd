extends Camera2D

const MIN_ZOOM: float = 0.1
const MAX_ZOOM: float = 1.0
const ZOOM_INCREMENT: float = 0.2
const ZOOM_RATE: float = 8.0
var _target_zoom: float = 1.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_LEFT:
			position -= event.relative * zoom

	if event.is_action_pressed("debug03"):
		zoom_in()
	if event.is_action_pressed("debug04"):
		zoom_out()
	
func _physics_process(delta: float) -> void:
	zoom = lerp(zoom, _target_zoom * Vector2.ONE, ZOOM_RATE * delta)
	set_physics_process(not is_equal_approx(zoom.x, _target_zoom))

func zoom_in():
	_target_zoom = max(_target_zoom - ZOOM_INCREMENT, MIN_ZOOM)
	set_physics_process(true)

func zoom_out():
	_target_zoom = max(_target_zoom + ZOOM_INCREMENT, MAX_ZOOM)
	set_physics_process(true)
