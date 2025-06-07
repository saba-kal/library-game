@tool
class_name NavigationRegion extends Node3D

@export_group("Sampling")
@export var partition_type: NavigationMesh.SamplePartitionType = NavigationMesh.SAMPLE_PARTITION_LAYERS

@export_group("Geometry")
@export var parsed_geometry_type: NavigationMesh.ParsedGeometryType = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
@export_flags_3d_navigation var collision_mask: int = 0xFFFFFFFF
@export var source_group_mode: NavigationMesh.SourceGeometryMode = NavigationMesh.SOURCE_GEOMETRY_GROUPS_WITH_CHILDREN
@export var source_group_name: String = "nav_mesh_group"

@export_group("Cells")
@export_range(0.01, 500.0, 0.01, "suffix:m") var cell_size: float = 0.25
@export_range(0.01, 500.0, 0.01, "suffix:m") var cell_height: float = 0.25
@export_range(0.0, 500.0, 0.01, "suffix:m") var border_size: float = 0.0

@export_group("Agents")
@export_range(0.0, 500.0, 0.01, "suffix:m") var height: float = 2.5
@export_range(0.0, 500.0, 0.01, "suffix:m") var radius: float = 0.7
@export_range(0.0, 500.0, 0.01, "suffix:m") var max_climb: float = 0.25
@export_range(0.2, 90, 0.01, "degrees") var max_slope: float = 45.0

@export_group("Regions")
@export_range(0.0, 150.0, 0.01, "suffix:m") var min_size: float = 10.0
@export_range(0.0, 150.0, 0.01, "suffix:m") var merge_size: float = 20.0

@export_group("Edges")
@export_range(0.0, 50.0, 0.01, "suffix:m") var max_length: float = 0.0
@export_range(0.1, 3.0, 0.01, "suffix:m") var max_error: float = 1.0

@export_group("Polygons")
@export_range(3, 12) var vertices_per_polygon: int = 6

@export_group("Details")
@export_range(0.1, 16.0, 0.01, "suffix:m") var sample_distance: float = 6.0
@export_range(0.0, 16.0, 0.01, "suffix:m") var sample_max_error: float = 1.0

@export_group("Filters")
@export_range(-50.0, 500.0, 0.01, "suffix:m") var mesh_min_height: float = 0.0
@export_range(-50.0, 500.0, 0.01, "suffix:m") var mesh_max_height: float = 3.0

@export_group("", "")
@export_tool_button("Bake NavigationMesh") var bake_action = bake_nav_mesh

var nav_mesh: NavigationMesh
var source_geometry: NavigationMeshSourceGeometryData3D
var callback_parsing: Callable
var callback_baking: Callable
var region_rid: RID
var nav_region: NavigationRegion3D


func _enter_tree() -> void:
	delayed_nav_mesh_load.call_deferred()


func delayed_nav_mesh_load():
	nav_region = $NavigationRegion
	var path: String = get_resource_path()
	if !path:
		return
	if !ResourceLoader.exists(path):
		printerr("A nav mesh has not been baked for this room. Missing resource: " + path)
		return
	nav_mesh = ResourceLoader.load(path)
	nav_region.navigation_mesh = nav_mesh
	NavigationServer3D.region_set_navigation_mesh(nav_region.get_region_rid(), nav_mesh)


func bake_nav_mesh() -> void:
	nav_region = $NavigationRegion
	nav_region.navigation_mesh.clear()

	nav_mesh = NavigationMesh.new()
	nav_mesh.sample_partition_type = partition_type
	nav_mesh.geometry_parsed_geometry_type = parsed_geometry_type
	nav_mesh.geometry_collision_mask = collision_mask
	nav_mesh.geometry_source_geometry_mode = source_group_mode
	nav_mesh.geometry_source_group_name = source_group_name
	nav_mesh.cell_size = cell_size
	nav_mesh.cell_height = cell_height
	nav_mesh.border_size = border_size
	nav_mesh.agent_height = height
	nav_mesh.agent_radius = radius
	nav_mesh.agent_max_climb = max_climb
	nav_mesh.agent_max_slope = max_slope
	nav_mesh.region_min_size = min_size
	nav_mesh.region_merge_size = merge_size
	nav_mesh.edge_max_length = max_length
	nav_mesh.edge_max_error = max_error
	nav_mesh.vertices_per_polygon = vertices_per_polygon
	nav_mesh.detail_sample_distance = sample_distance
	nav_mesh.detail_sample_max_error = sample_max_error
	nav_mesh.filter_baking_aabb = AABB(Vector3(-200.0, mesh_min_height, -200.0), Vector3(400.0, mesh_max_height, 400.0))
	
	callback_parsing = on_parsing_done
	callback_baking = on_baking_done
	region_rid = nav_region.get_region_rid()
	source_geometry = NavigationMeshSourceGeometryData3D.new()
	NavigationServer3D.region_set_enabled(region_rid, true)
	NavigationServer3D.region_set_map(region_rid, get_world_3d().get_navigation_map())
	parse_source_geometry.call_deferred()


func parse_source_geometry() -> void:
	source_geometry.clear()
	var root_node: Node3D = self

	# Parse the geometry from all mesh child nodes of the root node by default.
	NavigationServer3D.parse_source_geometry_data(
		nav_mesh,
		source_geometry,
		root_node,
		callback_parsing
	)


func on_parsing_done() -> void:
	# Bake the navigation mesh on a thread with the source geometry data.
	NavigationServer3D.bake_from_source_geometry_data_async(
		nav_mesh,
		source_geometry,
		callback_baking
	)


func on_baking_done() -> void:
	# Update the region with the updated navigation mesh.
	NavigationServer3D.region_set_navigation_mesh(region_rid, nav_mesh)
	nav_region.navigation_mesh = nav_mesh

	nav_mesh.take_over_path(get_resource_path())
	ResourceSaver.save(nav_mesh)


func get_resource_path() -> String:
	var scene_path = get_parent().scene_file_path
	if !scene_path:
		return ""
	return "res://assets/navigation/" + scene_path.get_file().get_basename() + "_NavigationMesh.res"
