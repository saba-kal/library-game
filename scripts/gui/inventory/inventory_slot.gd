@tool
class_name InventorySlot extends Node

@export var can_be_stacked: bool = false:
	set(val):
		can_be_stacked = val
		if $StackSizeLabel:
			$StackSizeLabel.visible = can_be_stacked


@export var is_disabled: bool = false:
	set(val):
		is_disabled = val
		var texture_rect: TextureRect = get_node_or_null("MarginContainer/TextureRect")
		if texture_rect != null:
			if is_disabled:
				texture_rect.modulate.a = 0.2
			else:
				texture_rect.modulate.a = 1.0


@export var texture: Texture:
	get:
		var texture_rect: TextureRect = get_node_or_null("MarginContainer/TextureRect")
		if texture_rect != null:
			return texture_rect.texture
		return null
	set(val):
		var texture_rect: TextureRect = get_node_or_null("MarginContainer/TextureRect")
		if texture_rect != null:
			texture_rect.texture = val


@export var color: Color:
	get:
		var texture_rect: TextureRect = get_node_or_null("MarginContainer/TextureRect")
		if texture_rect != null:
			return texture_rect.modulate
		return Color.WHITE
	set(val):
		var texture_rect: TextureRect = get_node_or_null("MarginContainer/TextureRect")
		if texture_rect != null:
			texture_rect.modulate = val


func set_stack_size(size: int) -> void:
	$StackSizeLabel.text = str(size)
