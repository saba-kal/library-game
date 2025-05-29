extends BossState

@export var boss: VampireBoss
@export var animation_tree: AnimationTree
@export var nav_agent: CharacterNavAgent


func Enter() -> void:
	nav_agent.is_disabled = true
	animation_tree.set("parameters/vampire_state/transition_request", "dead")
	boss.set_particle_effects_emitting(false)
