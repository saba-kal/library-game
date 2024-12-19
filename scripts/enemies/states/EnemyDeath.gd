extends State

@export var death_anim_name:String = ""
@export var death_anim_length:float = 0
@export var delete_timer: Timer

func _ready() -> void:
	if delete_timer:
		delete_timer.timeout.connect(_on_delete_timer_timeout)

func _on_delete_timer_timeout() -> void:
	print("it's deleting time")
	get_parent().get_parent().queue_free()

func Enter():
	anim_player.play(death_anim_name)
	delete_timer.start()

func Exit():
	pass

func Update(_delta: float):
	pass

func Physics_Update(_delta: float):
	pass
