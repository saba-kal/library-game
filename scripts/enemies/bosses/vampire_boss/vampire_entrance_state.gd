extends BossState

@export var boss: VampireBoss
@export var rotation_speed: float = 10.0
@export var animation_tree: AnimationTree

var player: Player


func _ready() -> void:
	animation_tree.animation_finished.connect(on_animation_finished)


func Enter() -> void:
	if !player:
		player = self.get_tree().get_first_node_in_group("player")
	animation_tree.set("parameters/intro_shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	boss.position = Vector3.ZERO


func Physics_Update(delta: float) -> void:
	var direction_to_player: Vector3 = (player.global_position - boss.global_position).normalized()
	Util.rotate_y_to_face_direction(
		boss,
		-direction_to_player,
		rotation_speed * delta)


func on_animation_finished(anim_name: String) -> void:
	if anim_name == "Intro":
		boss.change_state("Projectile")
	boss.set_particle_effects_emitting(true)
