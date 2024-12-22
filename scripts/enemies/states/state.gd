extends Node
class_name State
signal Transitioned

var enemy:EnemyBase = null
var mesh:Node3D = null
var nav_agent:NavigationAgent3D = null
var anim_player:AnimationPlayer = null
var player_target:CharacterBody3D
var collision_shape:CollisionShape3D = null

func SetTarget(target):
	if target:
		player_target = target
	else:
		player_target = null

func SetVariables(_enemy:EnemyBase, _mesh:Node3D, _nav_agent:NavigationAgent3D, _anim_player:AnimationPlayer, _collision_shape:CollisionShape3D):
	enemy = _enemy
	mesh = _mesh
	nav_agent = _nav_agent
	anim_player = _anim_player
	collision_shape = _collision_shape

func Enter():
	pass

func Exit():
	pass

func Update(_delta: float):
	pass

func Physics_Update(_delta: float):
	pass
