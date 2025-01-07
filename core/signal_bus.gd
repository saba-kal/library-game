extends Node

signal scene_change_initiated
signal room_key_collected
signal room_key_used
signal player_entered_interactable_area(interactable: Interactable)
signal player_exited_interactable_area(interactable: Interactable)
signal player_spawned(player: Player)
signal player_moved_to_room(room: RoomVariation)
