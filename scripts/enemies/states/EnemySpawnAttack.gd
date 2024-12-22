extends State


@export var pre_attack_delay: float = 1.0
@export var post_attack_delay: float = 1.0
@export var rotation_speed:float = 10.0
@export var object_to_spawn: PackedScene
@export var anim_name: String = "Attack"
@export var state_transition_upon_finish: String = "Wander"

var player: Player


func Enter() -> void:
	if !self.player:
		self.player = get_tree().get_first_node_in_group("player")

	self.nav_agent.target_position = self.enemy.global_position
	self.enemy.velocity = Vector3.ZERO
	self.anim_player.play(anim_name)

	await get_tree().create_timer(pre_attack_delay).timeout
	var spawned_object: Node3D = self.object_to_spawn.instantiate()
	self.get_tree().root.add_child(spawned_object)
	spawned_object.global_position = self.player.global_position

	await get_tree().create_timer(post_attack_delay).timeout
	Transitioned.emit(self, self.state_transition_upon_finish)
	self.enemy.disengage()


func Physics_Update(delta:float) -> void:
	var direction: Vector3 = (self.player.global_position - self.enemy.global_position).normalized()
	Util.rotate_y_to_face_direction(enemy, direction, rotation_speed * delta)
