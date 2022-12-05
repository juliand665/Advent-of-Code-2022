import Foundation
import AoC_Helpers
import SimpleParser
import Algorithms

typealias Crate = Character

struct Move {
	var count, source, target: Int
	
	func apply(to stacks: inout [[Crate]], shouldFlip: Bool) {
		let temp = stacks[source - 1].suffix(count)
		stacks[source - 1].removeLast(count)
		if shouldFlip { // temp.reversed() and temp have different types so no ?:
			stacks[target - 1].append(contentsOf: temp.reversed())
		} else {
			stacks[target - 1].append(contentsOf: temp)
		}
	}
}

let (rawGrid, rawMoves) = input().lines().split(whereSeparator: \.isEmpty).extract()

let grid = Matrix(rawGrid.dropLast().map { $0.dropFirst().striding(by: 4) })
let initial = grid.transposed().rows.map {
	$0.drop { $0 == " " }.reversed() as Array
}
let moves = rawMoves.map { $0.ints().splat(Move.init) }

print(String(moves.reduce(into: initial) { $1.apply(to: &$0, shouldFlip: true) }.map(\.last!)))
print(String(moves.reduce(into: initial) { $1.apply(to: &$0, shouldFlip: false) }.map(\.last!)))
