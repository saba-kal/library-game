class_name VampireBoss extends Boss

@export var particle_effects: Array[ParticleEffectPlayer]

@onready var states_container: Node = $States

var states: Dictionary[String, BossState]
var current_state: String = "Stand"


func _ready() -> void:
	set_particle_effects_emitting(false)
	super._ready()
	for state: BossState in states_container.get_children():
		states[state.name] = state
	await get_tree().physics_frame
	states[current_state].Enter()


func _process(delta: float) -> void:
	states[current_state].Update(delta)


func _physics_process(delta: float) -> void:
	states[current_state].Physics_Update(delta)


func start_boss_fight():
	change_state("Entrance")
	await get_tree().physics_frame
	visible = true


func reset_boss():
	position = Vector3.ZERO
	visible = false
	set_particle_effects_emitting(false)
	change_state("Stand")


func change_state(new_state_name: String) -> void:
	if new_state_name not in states:
		printerr("Unkown state name: " + new_state_name)
		return
	states[current_state].Exit()
	current_state = new_state_name
	states[current_state].Enter()


func set_particle_effects_emitting(emitting: bool) -> void:
	for effect: ParticleEffectPlayer in particle_effects:
		effect.set_all_effects_emitting(emitting)
