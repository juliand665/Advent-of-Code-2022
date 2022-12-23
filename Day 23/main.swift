import Foundation
import AoC_Helpers
import SimpleParser
import Algorithms
import Collections

let order: [Direction] = [.up, .down, .left, .right]

let initial = Matrix(input().lines().map { $0.map { $0 == "#" } })
let initialPositions = Set(initial.indexed().filter(\.element).map(\.index))

struct State {
	var elves: Set<Vector2>
	var round = 0
	
	mutating func step() {
		var proposals: [Vector2: Vector2?] = [:]
		for elf in elves {
			let prop = proposal(for: elf)
			if let existing = proposals[prop] {
				if let existing {
					assert(proposals[existing] == nil)
					proposals[existing] = existing
					proposals[prop] = .some(nil) // spicy nil: unavailable, but conflict already handled
				}
				proposals[elf] = elf
			} else {
				proposals[prop] = elf
			}
		}
		elves = .init(proposals.lazy.filter { $0.value ?? nil != nil }.map(\.key))
		round += 1
	}
	
	func proposal(for position: Vector2) -> Vector2 {
		let options = (0..<4).map { order[wrapping: round + $0] }.filter { direction in
			let proposal = position + direction.offset
			let toCheck = [
				proposal,
				proposal + direction.clockwise.offset,
				proposal - direction.clockwise.offset
			]
			return elves.isDisjoint(with: toCheck)
		}
		guard options.count < 4 else { return position }
		return options.first.map { position + $0.offset } ?? position
	}
}

var state = State(elves: initialPositions)
for _ in 0..<10 {
	state.step()
}
let xBounds = state.elves.lazy.map(\.x).minAndMax()!
let yBounds = state.elves.lazy.map(\.y).minAndMax()!
print((xBounds.max + 1 - xBounds.min) * (yBounds.max + 1 - yBounds.min) - state.elves.count)

measureTime {
	while true {
		let old = state
		state.step()
		guard state.elves != old.elves else { break }
	}
	print(state.round)
}
