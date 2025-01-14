extends CharacterState

@export var movement_state:CharacterState
@export var hurt_time: float
var timer: Timer

func _ready() -> void:
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(done)
	add_child(timer)


func enter(_previous_state_path: String, _data := {}) -> void:
	timer.start(hurt_time)
	Engine.time_scale = 0.8
	print("Playe hit. Add damaged effect here.")
	animation_tree.set("parameters/Transition/transition_request", "Ouchie")

func done() -> void:
	Engine.time_scale = 1.0
	finished.emit(movement_state.get_path())
