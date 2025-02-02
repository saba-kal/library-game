class_name DebugCommands extends Node

func goto_vampire() -> String:
	var haunted_floor = get_tree().current_scene
	if haunted_floor.name != "HauntedFloor":
		ChangeScene.to_scene("haunted_floor")
		get_tree().paused = false
		await SignalBus.scene_change_completed
		#and the whole scene, including the console, is reset
	var boss_cell: Vector2i = haunted_floor.map.boss_cell
	var room: RoomVariation = haunted_floor.room_dictionary[boss_cell]
	var player: Node3D = self.get_tree().get_first_node_in_group("player")
	player.position = room.position
	SignalBus.player_moved_to_room.emit(room)
	return "went to vampire"
