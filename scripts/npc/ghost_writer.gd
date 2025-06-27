extends Node3D

@export var min_dialogue_interval: float = 2.0
@export var max_dialogue_interval: float = 5.0
@export var start_dialogue: String
@export var random_dialogue_text: Array[String]
@export var end_dialogue: String

@onready var speech_bubble: SpeechBubble = $SpeechBubble3D

var dialogue_interval: float = 10000
var time_since_last_dialogue: float = 0
var player_is_fighting_boss: bool = false


func _ready() -> void:
	SignalBus.player_entered_boss_room.connect(on_boss_fight_started)
	SignalBus.boss_defeated.connect(on_boss_defeated)


func _process(delta: float) -> void:
	if !player_is_fighting_boss:
		return
	if time_since_last_dialogue >= dialogue_interval:
		speech_bubble.display_text(random_dialogue_text.pick_random())
		dialogue_interval = randf_range(min_dialogue_interval, max_dialogue_interval)
		time_since_last_dialogue = 0
	time_since_last_dialogue += delta


func on_boss_fight_started(_boss: Boss) -> void:
	speech_bubble.display_text(start_dialogue)
	dialogue_interval = randf_range(min_dialogue_interval, max_dialogue_interval)
	player_is_fighting_boss = true


func on_boss_defeated(_boss: Boss) -> void:
	player_is_fighting_boss = false
	speech_bubble.display_text(end_dialogue)
