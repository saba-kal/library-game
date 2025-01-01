class_name StateMachine extends Node

@export var enemy_body:EnemyBase = null
@export var mesh:Node3D = null
@export var anim_player:AnimationPlayer = null
@export var nav_agent:NavigationAgent3D = null
@export var intial_state:State = null
@export var aggro_timeout:Timer = null
@export var aggro_timeout_duration:float = 3
@export var detection_type:Area3D = null
@export var melee_attack_range:Area3D = null
@export var health: Health
@export var collision_shape: CollisionShape3D = null
@export var attached_sound_name:String
@export_flags_3d_physics var layers_searched

var player_target:CharacterBody3D
var engaged:bool = false
var player_inside_detection_area:bool = false
var sound_effect: AudioStreamPlayer3D

var current_state:State
var states:Dictionary = {}

## Sets up export variables for use if they're assigned.
func _ready() -> void:
	if aggro_timeout:
		aggro_timeout.timeout.connect(disengage)
	
	if detection_type:
		detection_type.body_entered.connect(player_entered_range)
		detection_type.body_exited.connect(player_exited_range)
	
	if melee_attack_range:
		melee_attack_range.body_entered.connect(player_entered_range)
		melee_attack_range.body_exited.connect(player_exited_range)
	
	## Loads children attached under state machine, and connects their transitioned signal.
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transitioned)
			child.SetVariables(enemy_body, mesh, nav_agent, anim_player, collision_shape)
	
	if intial_state:
		intial_state.Enter()
		current_state = intial_state

	call_deferred("setup_sound")
	self.health.changed.connect(self.on_health_changed)


func setup_sound() -> void:
	if self.attached_sound_name != null && self.attached_sound_name != "":
		self.sound_effect = AudioManager.attach_sound_3d(self.enemy_body, self.attached_sound_name)
		self.sound_effect.play()

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
		self.player_inside_detection_area = true
		print("Player in range.")
		if !aggro_timeout.is_stopped():
			aggro_timeout.stop()
		line_of_sight_check()

## When player leaves range, starts a timer, if it times out, stops aggroing player.
func player_exited_range(body:Node3D):
	if body.is_in_group("player"):
		print("Left Range")
		self.player_inside_detection_area = false
		aggro_timeout.start(aggro_timeout_duration)

## Raycasts for players while they are in the cone every 0.1 seconds.
func line_of_sight_check():
	var space_state = enemy_body.get_world_3d().direct_space_state
	var origin = Vector3(enemy_body.global_position.x, enemy_body.global_position.y+1,enemy_body.global_position.z)
	var end = Vector3(player_target.global_position.x, player_target.global_position.y+1,player_target.global_position.z)
	while (player_target != null) or (engaged == true):
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		var result = space_state.intersect_ray(query)
		if result:
			if result.collider.is_in_group("player"):
				engaged = true
				current_state.SetTarget(player_target)
				if self.player_inside_detection_area && !aggro_timeout.is_stopped():
					aggro_timeout.stop()
		await get_tree().create_timer(0.05).timeout

## Causes the enemy to disengage the player. Exact behavior of of what happens depends on the enemy's current state.
func disengage() -> void:
	print("Disengaging!")
	engaged = false
	player_target = null
	current_state.SetTarget(null)

func on_health_changed(health: int, _delta: int) -> void:
	if(health <= 0):
		on_child_transitioned(current_state, "Death")
		if self.sound_effect:
			self.sound_effect.stop()
