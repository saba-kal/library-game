extends Node

signal scene_change_initiated
signal scene_change_completed
signal boss_key_collected
signal room_key_collected
signal room_key_used
signal player_entered_interactable_area(interactable: Interactable)
signal player_exited_interactable_area(interactable: Interactable)
signal player_entered_boss_door_area(door: Door)
signal player_spawned(player: Player)
signal player_moved_to_room(room: RoomVariation)
signal player_entered_boss_room(boss: Boss)
signal player_exited_boss_room(boss: Boss)
signal player_damaged(damage: int)
signal player_died()
signal boss_defeated(boss: Boss)
signal enemy_quantity_changed(living: int, total: int)
signal enemy_died(enemy: EnemyBase)
signal set_player_controls_disabled(is_disabled: bool)
