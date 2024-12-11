extends Node

@export var enemy_body:CharacterBody3D
@export var mesh:MeshInstance3D = null
@export var nav_agent:NavigationAgent3D = null
@export var intial_state:State = null
@export var aggro_timeout:Timer = null
@export var aggro_timeout_duration:float = 3
@export var detection_type:Area3D = null
@export_flags_3d_physics var layers_searched

var player_target:CharacterBody3D
var engaged:bool = false

var current_state:State
var states:Dictionary = {}

## Sets up export variables for use if they're assigned.
func _ready() -> void:
	if aggro_timeout:
		aggro_timeout.timeout.connect(_on_aggro_timeout_timeout)
	
	if detection_type:
		detection_type.body_entered.connect(player_entered_range)
		detection_type.body_exited.connect(player_exited_range)
	
	## Loads children attached under state machine, and connects their transitioned signal.
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transitioned)
			child.SetVariables(enemy_body, mesh, nav_agent)
	
	if intial_state:
		intial_state.Enter()
		current_state = intial_state


## Runs the process function of the current state.
func _process(delta: float) -> void:
	if current_state:
		current_state.Update(delta)

## Runs the physics process function of the current state.
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.Physics_Update(delta)

## Uses transition signal depending on when/how it's called in the state, and sets it to the new state.
func on_child_transitioned(state, new_state_name):
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	
	if current_state:
		current_state.Exit()
	
	if !engaged:
		new_state.Enter()
		current_state = new_state
	else:
		current_state.SetTarget(player_target)
		new_state.Enter()
		current_state = new_state
		current_state.SetTarget(player_target)

## Uses the attached dectection area, and detects if player is within it. Then calls a function to raycast for the player.
func player_entered_range(body: Node3D):
	if body.is_in_group("player"):
		player_target = body
		print("Player in range.")
		line_of_sight_check()

## When player leaves range, starts a timer, if it times out, stops aggroing player.
func player_exited_range(body:Node3D):
	if body.is_in_group("player"):
		print("Left Range")
		aggro_timeout.start(aggro_timeout_duration)

## Raycasts for players while they are in the cone every 0.1 seconds.
func line_of_sight_check():
	var space_state = enemy_body.get_world_3d().direct_space_state
	var origin = Vector3(enemy_body.global_position.x, enemy_body.global_position.y+1,enemy_body.global_position.z)
	var end = Vector3(player_target.global_position.x, player_target.global_position.y+1,player_target.global_position.z)
	while (player_target != null) or (engaged == true):
		await get_tree().create_timer(0.1).timeout
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		var result = space_state.intersect_ray(query)
		if result:
			if result.collider.is_in_group("player"):
				engaged = true
				current_state.SetTarget(player_target)
				if !aggro_timeout.is_stopped():
					aggro_timeout.stop()

## When timer runs out sets target back to null on itself, and for the current state. 
func _on_aggro_timeout_timeout() -> void:
	print("Aggro Timed Out")
	engaged = false
	player_target = null
	current_state.SetTarget(null)
