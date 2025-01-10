extends CharacterState

var timer: Timer

func _ready() -> void:
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(done)
	add_child(timer)


func enter(_previous_state_path: String, _data := {}) -> void:
	timer.start()
	animation_tree.set("parameters/Transition/transition_request", "Death")

func done() -> void:
	ChangeScene.scene_change()
