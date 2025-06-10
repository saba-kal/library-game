# Global Game class to store data, such as player progress, items, level, etc.
extends Node

var room_key_count: int = 0

# TODO: utilize these values. Currently, only the room key count is used.
var player_has_boss_1_key: bool = false
var player_has_boss_2_key: bool = false
var player_has_boss_3_key: bool = false
var player_books: Array[int] = []


func reset_data() -> void:
	room_key_count = 0
	player_has_boss_1_key = false
	player_has_boss_2_key = false
	player_has_boss_3_key = false
	player_books = []