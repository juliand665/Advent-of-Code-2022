import Foundation
import AoC_Helpers
import SimpleParser
import Algorithms
import Collections

let rockShapes: [[Vector2]] = """
####

.#.
###
.#.

..#
..#
###

#
#
#
#

##
##
""".lineGroups().map {
	Matrix($0.reversed())
		.indexed()
		.filter { $0.element == "#" }
		.map(\.index)
}

let jetPattern = input().map(Direction.init).map(\.offset)

struct Cave: CustomStringConvertible {
	typealias Row = BitMask<UInt8>
	
	let width = 7
	var rows: Deque<Row> = []
	var offset = 0
	
	var jetIndex = 0
	var rocksDropped = 0
	
	var maxHeight: Int { rows.count + offset }
	
	mutating func nextJet() -> Vector2 {
		defer { jetIndex += 1 }
		return jetPattern[jetIndex % jetPattern.count]
	}
	
	mutating func nextRock() -> Int {
		defer { rocksDropped += 1 }
		return rocksDropped % rockShapes.count
	}
	
	func hasBlock(at position: Vector2) -> Bool? {
		guard (0..<width).contains(position.x) else { return nil }
		guard position.y >= offset else { return nil }
		guard position.y - offset < rows.count else { return false }
		return rows[position.y - offset].contains(position.x)
	}
	
	mutating func placeBlock(at position: Vector2) {
		let toInsert = position.y - offset - rows.count + 1
		if toInsert > 0 {
			rows.append(contentsOf: repeatElement([], count: toInsert))
		}
		rows[position.y - offset].insertNew(position.x)
	}
	
	func canPlace(rock: Int, at position: Vector2) -> Bool {
		rockShapes[rock].allSatisfy { hasBlock(at: $0 + position) == false }
	}
	
	mutating func place(rock: Int, at position: Vector2) {
		for part in rockShapes[rock] {
			placeBlock(at: part + position)
		}
		cleanUp()
	}
	
	mutating func cleanUp() {
		let delta = floorOffset() - offset
		rows.removeFirst(delta)
		offset += delta
	}
	
	private func floorOffset() -> Int {
		(0..<width)
			.map { x in
				(offset..<maxHeight).last {
					hasBlock(at: Vector2(x, $0)) != false
				} ?? 0
			}
			.min()!
	}
	
	var description: String {
		Matrix(rows.reversed().map { (0..<width).map($0.contains) })
			.binaryImage()
	}
	
	func key() -> Key {
		.init(
			jetIndex: jetIndex % jetPattern.count,
			rockIndex: rocksDropped % rockShapes.count
		)
	}
	
	struct Key: Hashable {
		var jetIndex: Int
		var rockIndex: Int
	}
}

var seen: [Cave.Key: Cave] = [:]

let target = 1_000_000_000_000
var cave = Cave()
while cave.rocksDropped < target {
	var position = Vector2(2, cave.maxHeight + 3)
	let rock = cave.nextRock()
	if cave.rocksDropped % 100 == 0 {
		print(cave.rocksDropped)
	}
	
	while true {
		let jetOffset = cave.nextJet()
		if cave.canPlace(rock: rock, at: position + jetOffset) {
			position += jetOffset
		}
		
		guard cave.canPlace(rock: rock, at: position - .unitY) else {
			cave.place(rock: rock, at: position)
			
			let key = cave.key()
			if let old = seen[key], old.rows == cave.rows {
				// this runs every time after succeeding once, but it's fine, it's a noop then
				let period = cave.rocksDropped - old.rocksDropped
				let repeats = (target - cave.rocksDropped) / period
				if repeats > 0 {
					print(cave)
					print("rocks:", cave.rocksDropped, key)
					print("period:", period)
					print("repeats:", repeats)
				}
				cave.rocksDropped += repeats * period
				cave.offset += repeats * (cave.offset - old.offset)
				if repeats > 0 {
					print(cave.maxHeight)
				}
			}
			seen[key] = cave
			
			break
		}
		
		position -= .unitY
	}
}

print(cave.maxHeight)
// example: 1514285714288
// answer: 1585673352422
