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
		lhs.precedes(rhs)!
	}
}

enum Value: Parseable, Equatable {
	case number(Int)
	case list([Self])
	
	init(from parser: inout Parser) {
		if parser.tryConsume("[") {
			var list: [Self] = []
			if !parser.tryConsume("]") {
				while true {
					list.append(.init(from: &parser))
					if parser.tryConsume("]") {
						break
					} else {
						parser.consume(",")
					}
				}
			}
			self = .list(list)
		} else {
			self = .number(parser.readInt())
		}
	}
	
	func precedes(_ other: Self) -> Bool? {
		switch (self, other) {
		case (.number(let lhs), .number(let rhs)):
			return lhs == rhs ? nil : lhs < rhs
		case (.number(let num), .list(let list)):
			return Self.list([.number(num)]).precedes(.list(list))
		case (.list(let list), .number(let num)):
			return Self.list(list).precedes(.list([.number(num)]))
		case (.list(let lhs), .list(let rhs)):
			return zip(lhs, rhs).firstNonNil { $0.precedes($1) }
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

let sorted = allPackets.sorted { $0.precedes($1)! }
let dividerIndices = sorted
	.enumerated()
	.filter { $1 == divider1 || $1 == divider2 }
	.map { $0.offset + 1 }
print(dividerIndices.product())
