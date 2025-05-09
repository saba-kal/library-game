class_name ParticleEffectPlayer extends Node3D

var particle_effects: Array[GPUParticles3D] = []


func _ready() -> void:
	for child: Node in get_children():
		if child is GPUParticles3D:
			particle_effects.append(child)


func set_all_effects_emitting(emitting: bool) -> void:
	for effect: GPUParticles3D in particle_effects:
		effect.emitting = emitting
