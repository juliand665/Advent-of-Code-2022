import Foundation
import AoC_Helpers
import SimpleParser
import Algorithms
import Collections

let inputMatrix = Matrix(input().lines())
let start = inputMatrix.positions().filter { inputMatrix[$0] == "S" }.onlyElement()!
let end = inputMatrix.positions().filter { inputMatrix[$0] == "E" }.onlyElement()!
let heights = inputMatrix.map { ($0 == "S" ? "a" : $0 == "E" ? "z" : $0) - "a" }

// poor man's dijkstra …or something
var distances = inputMatrix.map { _ in Int.max }
distances[end] = 0
var toExplore: Set<Vector2> = [end]
while !toExplore.isEmpty {
	let current = toExplore.removeFirst()
	let distance = distances[current] + 1
	let height = heights[current]
	let candidates = current.neighbors.filter {
		guard heights.isInMatrix($0) else { return false }
		return distance < distances[$0] && height - 1 <= heights[$0]
	}
	for candidate in candidates {
		distances[candidate] = distance
	}
	toExplore.formUnion(candidates)
}

print(distances[start])
print(zip(distances, heights).lazy.filter { $1 == 0 }.map(\.0).min()!)
