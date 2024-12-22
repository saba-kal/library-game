extends State

@export var change_state_after_timeout:bool = true
@export var change_state_after_player_detection:bool = false
@export var max_time_in_state:float = 5.0
@export var idle_anim_name:String = "Idle"
@export var state_transition_upon_player_detection:String = "Follow"
@export var state_transition_on_timeout:String = "Wander"

var time_in_state: float = 0


func Enter():
	self.anim_player.play(self.idle_anim_name)
	self.enemy.velocity = Vector3.ZERO
	self.nav_agent.target_position = self.enemy.global_position
	self.time_in_state = 0


func Physics_Update(delta: float) -> void:
	self.time_in_state += delta
	if self.change_state_after_player_detection && self.player_target:
		Transitioned.emit(self,self.state_transition_upon_player_detection)
		player_target = null
	elif self.change_state_after_timeout && self.time_in_state >= self.max_time_in_state:
		Transitioned.emit(self,self.state_transition_on_timeout)
