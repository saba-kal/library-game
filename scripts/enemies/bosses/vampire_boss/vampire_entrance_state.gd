extends BossState

@export var boss: VampireBoss
@export var rotation_speed: float = 10.0

var player: Player


func Enter() -> void:
	if !player:
		player = self.get_tree().get_first_node_in_group("player")


func Physics_Update(delta: float) -> void:
	var direction_to_player: Vector3 = (player.global_position - boss.global_position).normalized()
	Util.rotate_y_to_face_direction(
		boss,
		-direction_to_player,
		rotation_speed * delta)
