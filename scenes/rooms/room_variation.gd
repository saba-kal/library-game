extends Node3D
class_name RoomVariation

## {Lowercase Name, (The Exit)DoorDetectionSetup}
var doorways : Array[Array]

@onready var doors: Node3D = $Doors

func setup_doorway_ids():
	for x in doors.get_children():
		for y in doorways:
			if x is DoorDetectionSetup:
				if x.name.to_lower() == y[0]:
					x.door_id = y[1]
