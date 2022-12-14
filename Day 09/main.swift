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
		positions = positions.reductions {
			$0 + direction.offset
		} step: { prev, pos in
			let offset = (prev - pos)
			let step = offset.map { $0.clamped(to: -1...1) }
			guard step != offset else { return pos }
			return pos + step
		}
		
		visitedPart1.insert(positions[1])
		visitedPart2.insert(positions[9])
	}
}

print(visitedPart1.count)
print(visitedPart2.count)

// this is often useful!
extension Sequence {
	func reductions<T>(first: (Element) throws -> T, step: (T, Element) throws -> T) rethrows -> [T] {
		try chop().map { try $1.reductions(first($0), step) } ?? []
	}
}
