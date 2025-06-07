extends CharacterState

@export var movement_state: CharacterState
@export var hurt_time: float
@export var player_health: Health
@export var hurt_move_speed: float = 2.0
var timer: Timer
var original_move_speed: float

func _ready() -> void:
	original_move_speed = character.move_speed
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(done)
	add_child(timer)


func enter(_previous_state_path: String, _data := {}) -> void:
	timer.start(hurt_time)
	animation_tree.set("parameters/Transition/transition_request", "Ouchie")
	player_health.is_immune = true
	character.move_speed = hurt_move_speed
	AudioManager.play_3d("player_hurt", character.global_position)
	PostProcessing.play_player_hurt_effect()
	HitStopManager.frame_freeze(0.1, 0.2)


func done() -> void:
	finished.emit(movement_state.get_path())
	character.move_speed = original_move_speed
	player_health.is_immune = false
