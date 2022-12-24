import Foundation
import AoC_Helpers
import SimpleParser
import Algorithms
import Collections

struct Blizzard: Hashable {
	var position: Vector2
	var facing: Direction
	
	func stepped() -> Self {
		.init(position: map.wrap(position + facing.offset), facing: facing)
	}
}

let map = Matrix(input().lines().dropFirst().dropLast().map { $0.dropFirst().dropLast() })
let initialBlizzards = map.indexed()
	.filter { $1 != "." }
	.compactMap { Blizzard(position: $0, facing: .init($1)) }

let start = Vector2(0, -1)
let goal = Vector2(map.width - 1, map.height)

var blizzards = initialBlizzards
var blocked: Set<Vector2> = []
var time = 0

func step() {
	blizzards = blizzards.map { $0.stepped() }
	blocked = .init(blizzards.map(\.position))
	time += 1
}

func neighbors(of position: Vector2) -> some Sequence<Vector2> {
	chain(
		CollectionOfOne(position),
		Direction.allCases
			.lazy
			.map { position + $0.offset }
	)
	.filter { $0 == start || $0 == goal || map.isInMatrix($0) }
	.filter { !blocked.contains($0) }
}

func pathfind(from start: Vector2, to goal: Vector2) {
	var candidates: Set<Vector2> = [start]
	while !candidates.contains(goal) {
		step()
		candidates = .init(candidates.lazy.flatMap(neighbors(of:)))
	}
}

measureTime {
	pathfind(from: start, to: goal)
	print(time) // 228
}
measureTime {
	pathfind(from: goal, to: start)
	pathfind(from: start, to: goal)
	print(time) // 723
}
