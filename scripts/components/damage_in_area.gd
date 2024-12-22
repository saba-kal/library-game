extends Area3D

@export var delay: float = 0.0
@export var damage: int = 1

var healths_in_area: Array[Health] = []
var time_since_spawn: float = 0
var attacked = false


func _ready() -> void:
	self.body_entered.connect(self.on_body_entered)
	self.body_exited.connect(self.on_body_exited)


func _process(delta: float) -> void:
	if !self.attacked && self.time_since_spawn >= self.delay:
		self.attacked = true
		for health: Health in self.healths_in_area:
			health.take_damage(self.damage)
	self.time_since_spawn += delta


func on_body_entered(body: Node3D) -> void:
	var health: Health = Util.get_child_node_of_type(body, Health)
	if health:
		self.healths_in_area.append(health)


func on_body_exited(body: Node3D) -> void:
	var health: Health = Util.get_child_node_of_type(body, Health)
	if health:
		Util.remove_elem(self.healths_in_area, health)
