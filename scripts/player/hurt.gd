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
	animation_tree.set("parameters/Transition/transition_request", "Ouchie")

func done() -> void:
	finished.emit(movement_state.get_path())
