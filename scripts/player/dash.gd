extends CharacterState

@export var movement_state:CharacterState

@export var distance:float = 5.0
@export var duration:float = 0.2
@export_flags_3d_physics var dash_layer:int
@export_flags_3d_physics var dash_mask:int = 0x1

var default_layer:int
var default_mask:int
var speed:float
var timer:Timer

var dash_dir:Vector2

var blend_tree : AnimationNodeBlendTree
var transition : AnimationNodeTransition

func _ready() -> void:
	# Transition doesn't allow per-anim fade times. So I'm manually setting the fade to 0,
	# right before the dash players, and then setting it back to 0.2 at the state exit.
	blend_tree = animation_tree.tree_root
	transition = blend_tree.get("nodes/Actions/node")
	transition.xfade_time = 0
	
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(done)
	add_child(timer)
	
	default_layer = character.collision_layer
	default_mask = character.collision_mask

func enter(previous_state_path: String, data := {}) -> void:
	speed = distance / duration
	dash_dir = data.vector
	timer.start(duration)
	character.set_orientation_from_top_down_vector(dash_dir)
	character.collision_layer = dash_layer
	character.collision_mask = dash_mask
	AudioManager.play_3d("player_dash", self.character.global_position)
	animation_tree.set("parameters/Actions/transition_request", "Dash")

func exit() -> void:
	transition.xfade_time = 0.2
	character.collision_layer = default_layer
	character.collision_mask = default_mask
	character.velocity.x = 0
	character.velocity.z = 0

func physics_update(_delta: float) -> void:
	character.adjust_body_velocity(_delta, speed, 0.0)
	character.velocity.x = character.direction.x * speed
	character.velocity.z = character.direction.z * speed


func done() -> void:
	finished.emit(movement_state.get_path())
