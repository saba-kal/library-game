extends Room

func generation_chance(depth: int) -> float:
	if(depth == 0):
		return 0
	return 1
