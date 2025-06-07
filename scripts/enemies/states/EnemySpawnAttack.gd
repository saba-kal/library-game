extends State

@export var pre_attack_delay: float = 1.0
@export var post_attack_delay: float = 1.0
@export var rotation_speed: float = 10.0
@export var spawned_object_follow_speed: float = 2.0
@export var object_to_spawn: PackedScene
@export var spawn_immediately: bool
@export var anim_name: String = "Attack"
@export var state_transition_upon_finish: String = "Wander"

var player: Player
var spawned_object: Node3D = null
var time_in_state: float = 0

func Enter() -> void:
	if !self.player:
		self.player = get_tree().get_first_node_in_group("player")

	self.time_in_state = 0
	self.nav_agent.is_disabled = true
	self.enemy.velocity = Vector3.ZERO
	self.anim_player.play(anim_name)
	
	if self.spawn_immediately:
		self.spawned_object = self.object_to_spawn.instantiate()
		self.get_tree().root.add_child(spawned_object)
		self.spawned_object.global_position = self.player.global_position

	await get_tree().create_timer(pre_attack_delay).timeout
	if !self.spawn_immediately:
		self.spawned_object = self.object_to_spawn.instantiate()
		self.get_tree().root.add_child(spawned_object)
		self.spawned_object.global_position = self.player.global_position


func Physics_Update(delta: float) -> void:
	var direction: Vector3 = (self.player.global_position - self.enemy.global_position).normalized()
	if self.time_in_state <= self.pre_attack_delay:
		Util.rotate_y_to_face_direction(enemy, direction, rotation_speed * delta)
		if is_instance_valid(self.spawned_object):
			self.spawned_object.global_position = self.spawned_object.global_position.lerp(self.player.global_position, delta * self.spawned_object_follow_speed)
	elif self.time_in_state > self.pre_attack_delay + self.post_attack_delay:
		Transitioned.emit(self, self.state_transition_upon_finish)
		self.enemy.disengage()
	self.time_in_state += delta


func Exit() -> void:
	self.nav_agent.is_disabled = false
	if is_instance_valid(spawned_object):
		spawned_object.queue_free()
