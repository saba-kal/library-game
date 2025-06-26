# Credit: https://forum.godotengine.org/t/decal-image-aspect-ratio/103437/2
@tool
extends Decal

@export var maintain_aspect_ratio: bool = true
@export var width: float = 1.0 : set = set_width


func _ready():
	if texture_albedo and maintain_aspect_ratio:
		update_size()


func set_width(new_width):
	width = new_width
	if texture_albedo and maintain_aspect_ratio:
		update_size()


func update_size():
	var aspect_ratio = float(texture_albedo.get_width()) / float(texture_albedo.get_height())
	var height = width / aspect_ratio
	size = Vector3(width / 2, size.y, height / 2)
