extends State

@export var howl_anim_name: String
@export var howl_sound:AttachedSound3D
@export var chase_state:String = ""
@export var howl_speed:float = 1.0
@onready var howl_timer = $"Howl timer"
@onready var end_howl_timer = $"End-howl timer"

func _ready():
	howl_timer.timeout.connect(howl)
	end_howl_timer.timeout.connect(done)

func Enter():
	self.nav_agent.is_disabled = true
	self.enemy.velocity = Vector3.ZERO
	anim_player.play(howl_anim_name, -1, howl_speed)
	howl_timer.start(howl_timer.wait_time / howl_speed)

func howl():
	enemy.howl.emit()
	end_howl_timer.start(end_howl_timer.wait_time / howl_speed)
	if howl_sound:
		howl_sound.play()

func done():
	Transitioned.emit(self,chase_state)
	if howl_sound:
		howl_sound.stop()

func Exit() -> void:
	self.nav_agent.is_disabled = false
