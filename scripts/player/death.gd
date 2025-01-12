extends CharacterState

@export var umbrella: RigidBody3D
@export var drop_time: float
var drop_timer: Timer
var reset_timer: Timer

func _ready() -> void:
	reset_timer = Timer.new()
	reset_timer.one_shot = true
	reset_timer.timeout.connect(done)
	add_child(reset_timer)
	drop_timer = Timer.new()
	drop_timer.one_shot = true
	drop_timer.timeout.connect(drop)
	add_child(drop_timer)


func enter(_previous_state_path: String, _data := {}) -> void:
	reset_timer.start(6.35)
	drop_timer.start(drop_time)
	animation_tree.set("parameters/Transition/transition_request", "Death")

func drop() -> void:
	umbrella.reparent(character, true)
	umbrella.collision_layer = 1
	umbrella.collision_mask = 3
	umbrella.freeze = false

func done() -> void:
	ChangeScene.scene_change()
