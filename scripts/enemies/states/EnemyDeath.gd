extends State

@export var death_anim_name:String = ""
@export var death_anim_length:float = 0
@export var delete_timer: Timer

func _ready() -> void:
	if delete_timer:
		delete_timer.timeout.connect(_on_delete_timer_timeout)

func _on_delete_timer_timeout() -> void:
	get_parent().get_parent().queue_free()

func Enter():
	anim_player.play(death_anim_name)
	nav_agent.target_position = enemy.global_position
	enemy.velocity = Vector3.ZERO
	delete_timer.start()

func Exit():
	pass

func Update(_delta: float):
	pass

func Physics_Update(_delta: float):
	pass
