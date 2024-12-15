extends Node
class_name State
signal Transitioned

var enemy:CharacterBody3D = null
var mesh:Node3D = null
var nav_agent:NavigationAgent3D = null
var anim_player:AnimationPlayer = null
var player_target:CharacterBody3D

func SetTarget(target):
	if target:
		player_target = target
		print(player_target)
	else:
		player_target = null

func SetVariables(_enemy:CharacterBody3D, _mesh:Node3D, _nav_agent:NavigationAgent3D, _anim_player:AnimationPlayer):
	enemy = _enemy
	mesh = _mesh
	nav_agent = _nav_agent
	anim_player = _anim_player

func Enter():
	pass

func Exit():
	pass

func Update(_delta: float):
	pass

func Physics_Update(_delta: float):
	pass
