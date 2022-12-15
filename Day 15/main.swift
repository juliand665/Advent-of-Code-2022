import Foundation
import AoC_Helpers
import SimpleParser
import Algorithms
import Collections

struct Sensor: Parseable {
	var pos, closestBeacon: Vector2
	var radius: Int
	
	func range(at y: Int) -> ClosedRange<Int>? {
		let dist = abs(pos.y - y)
		let r = radius - dist
		guard r >= 0 else { return nil }
		return (pos.x - r)...(pos.x + r)
	}
	
	init(from parser: inout Parser) {
		(pos, closestBeacon) = parser.ints(allowSigns: true).splat { (Vector2($0, $1), Vector2($2, $3)) }
		radius = pos.distance(to: closestBeacon)
	}
}

let sensors = input().lines().map(Sensor.init)

let y = 2_000_000
measureTime {
	// didn't end up using this for part 2 because of the like 3x overhead of storing everything but it would totally work for that too
	var impossible = IndexSet()
	for sensor in sensors {
		guard let range = sensor.range(at: y) else { continue }
		impossible.insert(integersIn: range.clamped(to: 0...))
	}
	
	// remove positions we know to have sensors
	sensors
		.map(\.closestBeacon)
		.filter { $0.y == y }
		.forEach { impossible.remove($0.x) }
	
	print(impossible.count)
}
 
let limit = 4_000_000
measureTime {
	for y in 0...limit {
		var x = 0
		let ranges = sensors.compactMap { $0.range(at: y) }.sorted(on: \.lowerBound)
		while x < limit {
			guard let range = ranges.first(where: { $0.contains(x) }) else {
				print(x, y)
				return
			}
			x = range.upperBound + 1
		}
	}
}
