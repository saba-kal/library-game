extends Camera2D

@export var map_generation: _2DGeneration
@export var tile_map: TileMapLayer

var tile_width: int
var tile_height: int


func _ready() -> void:
	self.map_generation.generation_complete.connect(self.on_generation_complete)
	self.tile_width = self.tile_map.tile_set.tile_size.x
	self.tile_height = self.tile_map.tile_set.tile_size.y


func on_generation_complete() -> void:
	#Credit: https://www.reddit.com/r/godot/comments/18778ns/fitting_camera_to_tilemap/
	var tile_map_rect = tile_map.get_used_rect() #Get the tilemap bounding rect, this is in tile coordinate space
	var camera_rect = get_viewport_rect() #Get the camera viewport rect
	tile_map_rect.position *= Vector2i(tile_width, tile_height) #Adjust the tilemap bounding rect to world space
	tile_map_rect.size *= Vector2i(tile_width, tile_height) #Adjust the tilemap bounding rect to world space
	self.offset = tile_map_rect.position + Vector2i(tile_map_rect.size * 0.5) #Position the camera in the middle (You can also use camera.position)
	var x_ratio = 1.0 * camera_rect.size.x / tile_map_rect.size.x # The ratio of the width
	var y_ratio = 1.0 * camera_rect.size.y / tile_map_rect.size.y # The ratio of the height
	if x_ratio < y_ratio:
		self.zoom = Vector2(x_ratio, x_ratio)
	else:
		self.zoom = Vector2(y_ratio, y_ratio)
