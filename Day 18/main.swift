import Foundation
import AoC_Helpers
import SimpleParser
import Algorithms
import Collections

let positions = Set(input().lines().map(Vector3.init))

print(positions.map { $0.neighbors.count { !positions.contains($0) } }.sum())

let bounds: [ClosedRange<Int>] = positions
	.map(\.components)
	.transposed()
	.map { $0.minAndMax()! }
	.map(...)
	.map { $0.expanded(by: 1) } // allow fill to flood around the outside of the droplet

// flood fill the outside, within input bounds expanded by 1 along each axis
let minCorner = bounds.map(\.lowerBound).splat(Vector3.init)
var outside: Set<Vector3> = []
var toExplore: Set<Vector3> = [minCorner]
while let first = toExplore.popFirst() {
	let isInBounds = zip(bounds, first.components)
		.allSatisfy { $0.contains($1) }
	guard isInBounds else { continue }
	guard !positions.contains(first) else { continue }
	guard outside.insert(first).inserted else { continue }
	toExplore.formUnion(first.neighbors)
}

print(positions.map { $0.neighbors.count(where: outside.contains(_:)) }.sum())
