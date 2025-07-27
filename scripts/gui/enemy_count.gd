extends Control

enum PlayerProgress {
	ENTERED_HUB_ROOM = 0,
	ENTERED_ENEMY_ROOM = 1,
	COLLECTED_KEY = 2,
	FIGHTING_BOSS = 3,
	DEFEATED_BOSS = 4
}

@export var main_objective_label: Label
@export var room_objective_label: Label

var progress: PlayerProgress = PlayerProgress.ENTERED_HUB_ROOM


func _ready():
	room_objective_label.visible = false
	SignalBus.enemy_quantity_changed.connect(on_change_enemy_count)
	SignalBus.player_moved_to_room.connect(on_player_moved_to_room)
	SignalBus.room_key_collected.connect(on_room_key_collected)
	SignalBus.player_entered_boss_room.connect(on_player_entered_boss_room)
	SignalBus.player_exited_boss_room.connect(on_player_exited_boss_room)
	SignalBus.boss_defeated.connect(on_boss_defeated)


func on_change_enemy_count(living: int, total: int):
	if total == 0:
		room_objective_label.visible = false
	else:
		room_objective_label.visible = true
		if living > 0:
			room_objective_label.text = "ROOM OBJECTIVE\n- Defeat enemies "+str(total - living)+" / "+str(total)
		else:
			room_objective_label.text = "ROOM OBJECTIVE\n- Complete!"


func on_player_moved_to_room(room: RoomVariation) -> void:
	# Player exited the hub room.
	if progress == PlayerProgress.ENTERED_HUB_ROOM && room.tile_position != Vector2i.ZERO:
		progress = PlayerProgress.ENTERED_ENEMY_ROOM
		main_objective_label.text = "MAIN OBJECTIVE\n- Find the key"


func on_room_key_collected() -> void:
	if progress == PlayerProgress.ENTERED_ENEMY_ROOM:
		progress = PlayerProgress.COLLECTED_KEY
		main_objective_label.text = "MAIN OBJECTIVE\n- Find and defeat Count Montgue"


func on_player_entered_boss_room(boss: Boss):
	progress = PlayerProgress.FIGHTING_BOSS
	main_objective_label.text = "MAIN OBJECTIVE\n- Defeat Count Montague"
	room_objective_label.visible = false


func on_player_exited_boss_room(boss: Boss):
	room_objective_label.visible = true


func on_boss_defeated(boss: Boss):
	progress = PlayerProgress.DEFEATED_BOSS
	room_objective_label.visible = false
	main_objective_label.visible = false
