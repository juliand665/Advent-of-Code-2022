import Foundation
import AoC_Helpers
import SimpleParser
import Algorithms
import Collections

let rockTypes = """
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
""".lineGroups().map { Matrix<Bool>($0.reversed().map { $0.map { $0 == "#" } }) }

let jetPattern = input().map(Direction.init)

let width = 7

var cave = Matrix(width: 7, height: 5000, repeating: false)
var maxHeight = 0
var jetIndex = 0

func intersects(rock: Int, at position: Vector2) -> Bool {
	let rock = rockTypes[rock]
	return rock.indexed().contains { $0.element && cave.element(at: $0.index + position) != false }
}

func heightUntilFloor() -> Int {
	(0..<cave.width)
		.map { x in
			(0...).first {
				cave.element(at: Vector2(x, maxHeight - 1 - $0)) != false
			}!
		}
		.max()!
}

func byteRep(of row: [Bool]) -> UInt8 {
	row.reduce(0) { $0 << 1 | ($1 ? 1 : 0) }
}

struct CaveRep {
	var cave: [UInt8]
	var maxHeight: Int
	var rocks: Int
}

func caveRep() -> [UInt8] {
	cave.rows.prefix(heightUntilFloor()).map { byteRep(of: $0) }
}

var reps: [[CaveRep]] = .init(repeating: .init(repeating: .init(cave: [], maxHeight: 0, rocks: 0), count: jetPattern.count), count: rockTypes.count)

var droppedRows = 0

let target = 1_000_000_000_000
var i = 0
while i < target {
	var position = Vector2(2, maxHeight + 3)
	while true {
		let rock = i % rockTypes.count
		let jet = jetIndex % jetPattern.count
		jetIndex += 1
		
		let jetOffset = jetPattern[jet].offset
		if !intersects(rock: rock, at: position + jetOffset) {
			position += jetOffset
		}
		
		guard !intersects(rock: rock, at: position - .unitY) else {
			rockTypes[rock].indexed().filter(\.element).forEach { cave[$0.index + position] = true }
			maxHeight = max(maxHeight, position.y + rockTypes[rock].height)
			
			let rep = caveRep()
			let old = reps[rock][jet]
			if old.cave == rep {
				print("looped!")
				let repeats = (target - i) / (i - old.rocks)
				i += repeats * (i - old.rocks)
				droppedRows += repeats * (maxHeight - old.maxHeight)
			}
			reps[rock][jet] = .init(cave: rep, maxHeight: maxHeight, rocks: i)
			
			break
		}
		
		position -= .unitY
	}
	i += 1
}

print(maxHeight + droppedRows)
