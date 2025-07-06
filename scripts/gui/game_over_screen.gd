class_name GameOverScreen extends Control


@onready var defeat_message: Control = $Book/DefeatMessage
@onready var victory_message: Control = $Book/VictoryMessage
@onready var results_label: Label = $Book/ResultsLabel
@onready var retry_button: Button = $NavButtons/RetryButton
@onready var quit_button: Button = $NavButtons/QuitButton
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var total_kills: int = 0
var time_since_start: float = 0
var player_damage_taken: int = 0
var explored_room_count: int = 0
var explored_rooms: Dictionary[Vector2i, bool] = {}


func _ready() -> void:
	visible = false
	retry_button.pressed.connect(on_retry_pressed)
	quit_button.pressed.connect(on_quit_pressed)
	SignalBus.enemy_died.connect(on_enemy_died)
	SignalBus.player_moved_to_room.connect(on_player_moved_to_room)
	SignalBus.player_damaged.connect(on_player_damaged)


func _process(delta: float) -> void:
	time_since_start += delta


func show_defeat() -> void:
	defeat_message.visible = true
	victory_message.visible = false
	show_game_over()


func show_victory() -> void:
	defeat_message.visible = false
	victory_message.visible = true
	show_game_over()


func show_game_over() -> void:
	anim_player.play("fade_in")
	visible = true
	results_label.text = create_results_string()


func create_results_string() -> String:
	var minutes: float = time_since_start / 60.0
	var seconds: float = fmod(time_since_start, 60)
	return "Results:\n" +\
		"kills - %d\n" % total_kills +\
		"time - %02d:%02d\n" % [minutes, seconds] +\
		"damage taken - %d\n" % player_damage_taken +\
		"rooms explored - %d" % explored_room_count


func on_retry_pressed() -> void:
	ChangeScene.to_game_start()


func on_quit_pressed() -> void:
	ChangeScene.to_main_menu()


func on_enemy_died(_enemy: EnemyBase) -> void:
	total_kills += 1


func on_player_damaged(damage: int) -> void:
	player_damage_taken += damage
	print(player_damage_taken)


func on_player_moved_to_room(room: RoomVariation) -> void:
	if room.tile_position != Vector2i.ZERO && room.tile_position not in explored_rooms:
		explored_rooms[room.tile_position] = true
		explored_room_count += 1
