extends Node
class_name State
signal Transitioned

var player_target:CharacterBody3D

func SetTarget(target):
	if target:
		player_target = target
		print(player_target)
	else:
		player_target = null

func Enter():
	pass

func Exit():
	pass

func Update(_delta: float):
	pass

func Physics_Update(_delta: float):
	pass
