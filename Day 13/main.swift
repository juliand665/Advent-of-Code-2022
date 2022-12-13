import Foundation
import AoC_Helpers
import SimpleParser
import Algorithms
import Collections

struct Pair {
	var lhs, rhs: Value
	
	init(lines: some Sequence<Substring>) {
		(lhs, rhs) = lines.map(Value.init).extract()
	}
	
	func isInOrder() -> Bool {
		Value.areInOrder(lhs, rhs)!
	}
}

enum Value: Parseable, Equatable {
	case number(Int)
	case list([Self])
	
	init(from parser: inout Parser) {
		if parser.tryConsume("[") {
			if parser.tryConsume("]") {
				self = .list([])
			} else {
				self = .list(.init(from: &parser))
				parser.consume("]")
			}
		} else {
			self = .number(parser.readInt())
		}
	}
	
	static func areInOrder(_ lhs: Self, _ rhs: Self) -> Bool? {
		switch (lhs, rhs) {
		case (.number(let lhs), .number(let rhs)):
			return lhs == rhs ? nil : lhs < rhs
		case (.number, .list):
			return areInOrder(.list([lhs]), rhs)
		case (.list, .number):
			return areInOrder(lhs, .list([rhs]))
		case (.list(let lhs), .list(let rhs)):
			return zip(lhs, rhs).firstNonNil(areInOrder)
			?? (lhs.count == rhs.count ? nil : lhs.count < rhs.count)
		}
	}
}

let pairs = input().lineGroups().map(Pair.init)
let correct = pairs
	.enumerated()
	.filter { $1.isInOrder() }
	.map { $0.offset + 1 }
print(correct.sum())

let divider1 = Value.list([.list([.number(2)])])
let divider2 = Value.list([.list([.number(6)])])
let allPackets = pairs.flatMap { [$0.lhs, $0.rhs] } + [divider1, divider2]

let sorted = allPackets.sorted { Value.areInOrder($0, $1)! }
let dividerIndices = sorted
	.enumerated()
	.filter { $1 == divider1 || $1 == divider2 }
	.map { $0.offset + 1 }
print(dividerIndices.product())
