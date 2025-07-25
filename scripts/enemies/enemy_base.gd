class_name EnemyBase extends CharacterBody3D

signal death

var state_machine: StateMachine


func _ready() -> void:
	# Using this utility function so that retreiving this node does not depend on node name & path.
	self.state_machine = Util.get_child_node_of_type(self, StateMachine)


## Causes the enemy to disengage the player. Exact behavior of of what happens depends on the enemy's current state.
func disengage() -> void:
	if self.state_machine:
		self.state_machine.disengage()


func kill() -> void:
	state_machine.kill()
