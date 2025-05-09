extends BossState

@export var animation_tree: AnimationTree


func Enter() -> void:
	animation_tree.set("parameters/vampire_state/transition_request", "stand")
