import Foundation
import AoC_Helpers
import SimpleParser
import Algorithms
import Collections

let paths = input().lines().map { $0.components(separatedBy: " -> ").map(Vector2.init) }

var world: Set<Vector2> = []

for path in paths {
	world.formUnion(path.adjacentPairs().lazy.flatMap { start, end in
		let delta = end - start
		let distance = delta.absolute.sum
		let step = delta / distance
		return sequence(first: start) { $0 + step }.prefix(distance)
	})
	world.insert(path.last!)
}

let highestY = paths.lazy.joined().map(\.y).max()!
let fallOffsets: [Vector2] = [.init(0, 1), .init(-1, 1), .init(1, 1)]

measureTime {
	let start = Vector2(500, 0)
	var hasEnteredAbyss = false
	
	for sandCount in 0... {
		var pos = start
		while pos.y < highestY + 1 {
			let destination = fallOffsets.first { !world.contains(pos + $0) }
			guard let destination else { break }
			pos += destination
		}
		
		world.insert(pos)
		
		// part 1
		if !hasEnteredAbyss && pos.y > highestY {
			hasEnteredAbyss = true
			print(sandCount)
		}
		
		// part 2
		if pos == start {
			print(sandCount + 1)
			return
		}
	}
}
