import Foundation
import AoC_Helpers
import SimpleParser
import Algorithms

var positions = Array(repeating: Vector2.zero, count: 10)

var visitedPart1: Set<Vector2> = []
var visitedPart2: Set<Vector2> = []

visitedPart1.insert(positions[1])
visitedPart2.insert(positions[9])

for line in input().lines() {
	var parser = Parser(reading: line)
	let direction: Direction = parser.readValue()
	parser.consume(" ")
	let count = parser.readInt()
	
	for _ in 0..<count {
		positions = positions.dropFirst().reductions(positions[0] + direction.offset) { prev, pos in
			guard (prev - pos).absolute.maxComponent > 1 else { return pos }
			// need to move closer to prev
			
			switch prev.distance(to: pos) {
			case 2, 4: // straight line (incl. diagonal)
				return (pos + prev) / 2
			case 3: // some other shape—move diagonally to be directly next to prev
				return pos.neighborsWithDiagonals
					.filter { $0.neighbors.contains(prev) }
					.onlyElement()!
			default:
				fatalError()
			}
		}
		
		visitedPart1.insert(positions[1])
		visitedPart2.insert(positions[9])
	}
}

print(visitedPart1.count)
print(visitedPart2.count)
