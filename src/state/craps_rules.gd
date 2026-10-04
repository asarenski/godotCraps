class_name CrapsRules

enum Outcome {
	WIN,
	LOSE,
	ESTABLISH_POINT,
	CONTINUE,
}

static func resolve(roll: int, point) -> int:
	if point == null:
		match roll:
			7, 11:
				return Outcome.WIN
			2, 3, 12:
				return Outcome.LOSE
			_:
				return Outcome.ESTABLISH_POINT
	else:
		if roll == point:
			return Outcome.WIN
		if roll == 7:
			return Outcome.LOSE
		return Outcome.CONTINUE
