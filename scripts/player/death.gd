extends CharacterState

@export var umbrella: Node3D
@export var drop_time: float
var drop_timer: Timer
var reset_timer: Timer
@onready var player: Player = $"../.."

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
	player.velocity = Vector3.ZERO
	reset_timer.start(6.35)
	drop_timer.start(drop_time)
	animation_tree.set("parameters/Transition/transition_request", "Death")
	AudioManager.play_3d("player_death", character.global_position)
	PostProcessing.play_player_hurt_effect()

func drop() -> void:
	umbrella.reparent(character, true)

func done() -> void:
	ChangeScene.scene_change()
