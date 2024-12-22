class_name EnemyBase extends CharacterBody3D

var state_machine: StateMachine
var is_disabled: bool = false


func _ready() -> void:
	# Using this utility function so that retreiving this node does not depend on node name & path.
	self.state_machine = Util.get_child_node_of_type(self, StateMachine)


func _physics_process(delta: float) -> void:
	if self.is_disabled:
		return
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()


## Causes the enemy to disengage the player. Exact behavior of of what happens depends on the enemy's current state.
func disengage() -> void:
	if self.state_machine:
		self.state_machine.disengage()
