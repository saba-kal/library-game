extends Node
class_name EnemyBehavior

signal enemy_idle
signal enemy_moving
signal enemy_attacking
signal enemy_stunned

@export var body_controlled:EnemyBase
@export var nav_agent:NavigationAgent3D
var player_target:CharacterBody3D

# States - Most paired with signals to make animation accross multiple enemies easier.
var is_idle:bool = true
var is_engaged:bool = false
var is_moving:bool = false
var is_attacking:bool = false
var is_stunned:bool = false

var steps:int

func _ready() -> void:
	if nav_agent:
		nav_agent.target_reached.connect(finished_movement_action)

func _process(delta: float) -> void:
	behavior_tree()

func behavior_tree():
	if is_idle:
		print("Idle")
		return
	else:
		if is_engaged:
			perform_movement_type()
		else:
			return

func perform_movement_type() -> bool:
	var target_pos = 
	nav_agent.target_position = target_pos
	return true


func finished_movement_action():
	is_moving = false
	print("Finished move Action")
