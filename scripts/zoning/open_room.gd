extends Room

func generation_chance(depth: int) -> float:
    return max(1 - (depth as float / 2), 0)
