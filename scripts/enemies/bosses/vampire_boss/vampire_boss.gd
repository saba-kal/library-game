class_name VampireBoss extends Boss

@export_range(0, 1, 0.05) var phase_2_health: float = 0.7
@export_range(0, 1, 0.05) var phase_3_health: float = 0.35
@export var room_center_marker: Marker3D
@export var phase_2_minion_positions: Array[Marker3D]
@export var phase_3_minion_positions: Array[Marker3D]
@export var particle_effects: Array[ParticleEffectPlayer]

@onready var health: Health = $Health
@onready var states_container: Node = $States

var states: Dictionary[String, BossState]
var current_state: String = "Stand"
var phase: int = 1


func _ready() -> void:
	health.changed.connect(on_health_changed)
	set_particle_effects_emitting(false)
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
	print("New boss state: " + new_state_name)
	states[current_state].Exit()
	current_state = new_state_name
	states[current_state].Enter()


func set_particle_effects_emitting(emitting: bool) -> void:
	for effect: ParticleEffectPlayer in particle_effects:
		effect.set_all_effects_emitting(emitting)


func on_health_changed(health_amount:int, delta:int, damage_sender:CharacterBody3D) -> void:
	var health_percent: float = health.current / float(health.maximum)
	print(health_percent)
	if health.current <= 0:
		if reward_on_death != null:
			var reward_instance: Node3D = reward_on_death.instantiate()
			get_tree().root.add_child(reward_instance)
			reward_instance.global_position = global_position
		death.emit()
		self.queue_free()
	elif phase == 1 && health_percent <= phase_2_health:
		print("Vampire boss entering phase 2")
		phase = 2
		change_state("SpawnMinion")
	elif phase == 2 && health_percent <= phase_3_health:
		print("Vampire boss entering phase 3")
		phase = 3
		change_state("SpawnMinion")
