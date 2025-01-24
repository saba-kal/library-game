extends State

@export var howl_anim_name: String
@export var howl_sound:AttachedSound3D
@export var chase_state:String = ""
@onready var howl_timer = $"Howl timer"
@onready var end_howl_timer = $"End-howl timer"

func _ready():
	howl_timer.timeout.connect(howl)
	end_howl_timer.timeout.connect(done)

func Enter():
	self.nav_agent.target_position = self.enemy.global_position
	self.enemy.velocity = Vector3.ZERO
	anim_player.play(howl_anim_name)
	howl_timer.start()

func howl():
	enemy.howl.emit()
	end_howl_timer.start()
	if howl_sound:
		howl_sound.play()

func done():
	Transitioned.emit(self,chase_state)
	if howl_sound:
		howl_sound.stop()
