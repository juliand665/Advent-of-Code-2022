import Foundation
import AoC_Helpers
import SimpleParser
import Algorithms
import Collections

struct Path: Parseable {
	var steps: [Step] = []
	
	init(from parser: inout Parser) {
		while !parser.isDone {
			if parser.tryConsume("L") {
				steps.append(.turn(right: false))
			} else if parser.tryConsume("R") {
				steps.append(.turn(right: true))
			} else {
				steps.append(.advance(parser.readInt()))
			}
		}
	}
	
	enum Step {
		case advance(Int)
		case turn(right: Bool)
	}
}

let (rawMap, rawPath) = input().lineGroups().extract()
let width = rawMap.map(\.count).max()!
let map = Matrix(
	rawMap.map { $0 + repeatElement(" ", count: width - $0.count) }
)
let path = Path(rawValue: rawPath.onlyElement()!)

let startX = map.rows.first!.firstIndex(of: ".")!
let start = Vector2(startX, 0)

let size = 50

let parts = Set(
	Matrix(width: map.width / size, height: map.height / size, repeating: 0)
		.positions()
		.filter { map[$0 * size] != " " }
)

func fold(from part: Vector2, in direction: Direction) -> (Vector2, Direction) {
	// i just know there's a way to compute this, but i wasted way too much time trying to find it lol
	switch (part.x, part.y, direction) {
	case (1, 0, .up):
		return (.init(0, 3), .right)
	case (1, 0, .left):
		return (.init(0, 2), .right)
	case (2, 0, .up):
		return (.init(0, 3), .up)
	case (2, 0, .right):
		return (.init(1, 2), .left)
	case (2, 0, .down):
		return (.init(1, 1), .left)
	case (1, 1, .left):
		return (.init(0, 2), .down)
	case (1, 1, .right):
		return (.init(2, 0), .up)
	case (0, 2, .up):
		return (.init(1, 1), .right)
	case (0, 2, .left):
		return (.init(1, 0), .right)
	case (1, 2, .right):
		return (.init(2, 0), .left)
	case (1, 2, .down):
		return (.init(0, 3), .left)
	case (0, 3, .left):
		return (.init(1, 0), .down)
	case (0, 3, .down):
		return (.init(2, 0), .down)
	case (0, 3, .right):
		return (.init(1, 2), .up)
	default:
		fatalError()
	}
}

func wrap(_ position: Vector2) -> Vector2 {
	var position = position
	if position.x >= map.width {
		position.x -= map.width
	} else if position.x < 0 {
		position.x += map.width
	}
	if position.y >= map.height {
		position.y -= map.height
	} else if position.y < 0 {
		position.y += map.height
	}
	return position
}

struct State {
	var position: Vector2
	var facing: Direction
	var isPart2 = false
	
	var password: Int {
		let dirs: [Direction] = [.right, .down, .left, .up]
		return (position.y + 1) * 1000 + (position.x + 1) * 4 + dirs.firstIndex(of: facing)!
	}
	
	mutating func process(_ path: Path) {
		for step in path.steps {
			process(step)
		}
	}
	
	mutating func process(_ step: Path.Step) {
		switch step {
		case .turn(let right):
			facing = facing.rotated(by: right ? 1 : -1)
		case .advance(let distance):
			advance(by: distance)
		}
	}
	
	mutating func advance(by distance: Int) {
		for _ in 0..<distance {
			var next = self
			next.step()
			let tile = map[next.position]
			if tile == "#" {
				break
			} else if tile == "." {
				self = next
			} else {
				fatalError("\(tile)")
			}
		}
	}
	
	mutating func step() {
		if !isPart2 {
			flatStep()
		} else {
			cubeStep()
		}
	}
	
	mutating func flatStep() {
		let dir = facing.offset
		repeat {
			position = wrap(position + dir)
		} while map[position] == " "
	}
	
	mutating func cubeStep() {
		let next = position + facing.offset
		let tile = map.element(at: next)
		guard tile == nil || tile == " " else {
			position = next
			return
		}
		
		let facePos = position / size
		let (newFacePos, newFacing) = fold(from: facePos, in: facing)
		
		var offsetWithinFace = Vector2(next.x %% size, next.y %% size)
		while facing != newFacing {
			// rotate clockwise
			offsetWithinFace = .init(size - offsetWithinFace.y - 1, offsetWithinFace.x)
			facing = facing.rotated()
		}
		position = newFacePos * size + offsetWithinFace
	}
}

let initialState = State(position: start, facing: .right)

do {
	var state = initialState
	state.process(path)
	print(state.password) // 165094
}

do {
	var state = initialState
	state.isPart2 = true
	state.process(path)
	print(state.password) // 95316
}
