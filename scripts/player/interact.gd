extends Node


var nearby_interactibles: Array[Interactable] = []


func _ready() -> void:
	SignalBus.player_entered_interactable_area.connect(self.on_player_entered_interactable_area)
	SignalBus.player_exited_interactable_area.connect(self.on_player_exited_interactable_area)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		for interactable: Interactable in self.nearby_interactibles:
			interactable.interact()


func on_player_entered_interactable_area(interactable: Interactable) -> void:
	self.nearby_interactibles.append(interactable)


func on_player_exited_interactable_area(interactable: Interactable) -> void:
	Util.remove_elem(self.nearby_interactibles, interactable)
