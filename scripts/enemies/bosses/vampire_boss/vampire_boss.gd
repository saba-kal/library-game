class_name VampireBoss extends Boss

@onready var states_container: Node = $States

var states: Dictionary[String, BossState]
var current_state: String = "Entrance"


func _ready() -> void:
	super._ready()
	for state: BossState in self.states_container.get_children():
		states[state.name] = state
	await get_tree().physics_frame
	self.states[self.current_state].Enter()


func _process(delta: float) -> void:
	self.states[self.current_state].Update(delta)


func _physics_process(delta: float) -> void:
	self.states[self.current_state].Physics_Update(delta)


func start_boss_fight():
	self.change_state("Projectile")


func change_state(new_state_name: String) -> void:
	if new_state_name not in self.states:
		printerr("Unkown state name: " + new_state_name)
		return
	self.states[self.current_state].Exit()
	self.current_state = new_state_name
	self.states[self.current_state].Enter()
