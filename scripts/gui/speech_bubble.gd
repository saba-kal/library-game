class_name SpeechBubble extends Node

@onready var label: Label = $SubViewport/SpeechBubble/Label
@onready var letter_display_timer: Timer = $LetterDisplayTimer
@onready var dialogue_duration_timer: Timer = $DialogueDurationTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer


var current_text: String
var text_pos: int


func _ready() -> void:
	animation_player.play("RESET")
	letter_display_timer.timeout.connect(display_next_letter)
	dialogue_duration_timer.timeout.connect(hide_dialogue)
	animation_player.animation_finished.connect(on_animation_finished)


func display_text(text: String) -> void:
	current_text = text
	animation_player.stop()
	letter_display_timer.stop()
	dialogue_duration_timer.stop()
	label.text = ""
	text_pos = 0
	animation_player.play("show_dialogue")


func display_next_letter() -> void:
	if text_pos >= len(current_text):
		letter_display_timer.stop()
		dialogue_duration_timer.start()
	else:
		label.text += current_text[text_pos]
		text_pos += 1


func hide_dialogue() -> void:
	animation_player.play("hide_dialogue")


func on_animation_finished(anim_name: String) -> void:
	if anim_name == "show_dialogue":
		# Starts the text animation. This will call display_next_letter in 0.05 second intervals.
		# Interval value can be configured on the LetterDisplayTimer node.
		letter_display_timer.start()
