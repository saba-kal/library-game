extends Node

signal scene_change_initiated
signal scene_change_completed
signal boss_key_collected
signal room_key_collected
signal room_key_used
signal player_entered_interactable_area(interactable: Interactable)
signal player_exited_interactable_area(interactable: Interactable)
signal player_spawned(player: Player)
signal player_moved_to_room(room: RoomVariation)
signal player_entered_boss_room(boss: Boss)
signal player_exited_boss_room(boss: Boss)
