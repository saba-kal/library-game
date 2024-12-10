extends CharacterBody3D
class_name EnemyBase
signal engage_player
signal aggro_lost

@export var aggro_timeout_duration:float = 3
@export var detection_type:Area3D = null
@export_flags_3d_physics var layers_searched

var player_target:CharacterBody3D = null
var engaged:bool = false

@onready var aggro_timeout: Timer = %AggroTimeout

func _ready() -> void:
	if detection_type:
		detection_type.body_entered.connect(player_entered_range)
		detection_type.body_exited.connect(player_exited_range)

func _physics_process(_delta: float) -> void:
	move_and_slide()

func player_entered_range(body: Node3D):
	if body.is_in_group("player"):
		player_target = body
		line_of_sight_check()

func player_exited_range(body:Node3D):
	if body.is_in_group("player"):
		aggro_timeout.start(aggro_timeout_duration)

func line_of_sight_check():
	var space_state = get_world_3d().direct_space_state
	var origin = Vector3(global_position.x, global_position.y+1,global_position.z)
	var end = Vector3(player_target.global_position.x, player_target.global_position.y+1,player_target.global_position.z)
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	var result = space_state.intersect_ray(query)
	if result:
		if result.collider.is_in_group("player"):
			engaged = true
			engage_player.emit()
			if !aggro_timeout.is_stopped():
				aggro_timeout.stop()

func _on_aggro_timeout_timeout() -> void:
	player_target = null
	engaged = false
	aggro_lost.emit()
