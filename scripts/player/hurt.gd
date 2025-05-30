extends CharacterState

@export var movement_state:CharacterState
@export var hurt_time: float
@export var player_health: Health
var timer: Timer

func _ready() -> void:
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(done)
	add_child(timer)


func enter(_previous_state_path: String, _data := {}) -> void:
	timer.start(hurt_time)
	Engine.time_scale = 0.5
	print("Player hit. Add damaged effect here.")
	animation_tree.set("parameters/Transition/transition_request", "Ouchie")
	player_health.is_immune = true

func done() -> void:
	Engine.time_scale = 1.0
	finished.emit(movement_state.get_path())
	player_health.is_immune = false
