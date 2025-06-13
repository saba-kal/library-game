class_name Projectile extends Area3D

signal collided(body: Node3D)

@export var on_destroy_effect: PackedScene
@export var spawn_sound_name: String
@export var hit_sound_name: String
@export_flags_3d_physics var default_mask: int
@export_flags_3d_physics var parried_mask: int

# These are set by the nodes that spawn projectiles. They should not be exposed via export.
var damage: int = 1
var speed: float = 10.0
var direction: Vector3

# Private variables
var velocity: Vector3
var is_parried: bool = false


func _ready() -> void:
	self.velocity = self.direction * self.speed
	self.collision_mask = default_mask
	self.body_entered.connect(self.on_body_entered)
	await get_tree().physics_frame
	AudioManager.play_3d(self.spawn_sound_name, self.global_position)


func _physics_process(delta: float) -> void:
	self.look_at(self.global_transform.origin + self.direction, Vector3.UP)
	self.global_position = self.global_position + (self.velocity * delta)


func on_body_entered(body: Node3D):
	if self.on_destroy_effect != null:
		var effect: Node3D = self.on_destroy_effect.instantiate()
		self.get_tree().root.add_child(effect)
		effect.global_position = self.global_position
	var health: Health = Util.get_child_node_of_type(body, Health)
	if health != null:
		health.take_damage(self.damage)
	self.collided.emit(body)
	AudioManager.play_3d(hit_sound_name, global_position)
	self.queue_free()


func get_parried(_body: Node3D):
	if is_parried:
		return
	collision_mask = parried_mask
	velocity = - velocity
	is_parried = true
	AudioManager.play_3d("parry_hit", global_position)
