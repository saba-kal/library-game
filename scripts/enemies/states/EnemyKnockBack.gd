class_name EnemyKnockBack extends State

@export var knock_back_duration: float = 0.2
@export var state_duration: float = 0.3
@export var knock_back_speed: float = 500.0
@export var anim_name: String

var player: Player
var knock_back_direction: Vector3
var time_since_state_start: float


func Init() -> void:
	player = get_tree().get_first_node_in_group("player")


func Enter() -> void:
	time_since_state_start = 0
	nav_agent.is_disabled = true
	anim_player.play(anim_name)
	knock_back_direction = (enemy.global_position - player.global_position).normalized()
	Util.rotate_y_to_face_direction(enemy, -knock_back_direction, 1)


func Physics_Update(delta: float):
	if time_since_state_start < knock_back_duration:
		enemy.velocity = knock_back_direction * knock_back_speed * delta
		enemy.move_and_slide()

	if time_since_state_start >= state_duration:
		if enemy.state_machine.previous_state.name != name:
			Transitioned.emit(self, enemy.state_machine.previous_state.name)
		else:
			Transitioned.emit(self, enemy.state_machine.intial_state.name)

	time_since_state_start += delta


func Exit() -> void:
	nav_agent.is_disabled = false
