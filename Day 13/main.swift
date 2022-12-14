import Foundation
import AoC_Helpers
import SimpleParser
import Algorithms
import Collections

infix operator <? // < that can return nil

enum TreePacket: Parseable, Equatable {
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
	
	static func < (_ lhs: Self, _ rhs: Self) -> Bool {
		(lhs <? rhs)!
	}
	
	static func <? (_ lhs: Self, _ rhs: Self) -> Bool? {
		switch (lhs, rhs) {
		case (.number(let lhs), .number(let rhs)):
			return lhs == rhs ? nil : lhs < rhs
		case (.number, .list):
			return .list([lhs]) <? rhs
		case (.list, .number):
			return lhs <? .list([rhs])
		case (.list(let lhs), .list(let rhs)):
			return zip(lhs, rhs).firstNonNil(<?)
			?? (lhs.count == rhs.count ? nil : lhs.count < rhs.count)
		}
	}
}

typealias Packet = TreePacket
//typealias Packet = FlatPacket

let pairs = input().lineGroups().map { $0.map(Packet.init) }
let correct = pairs
	.enumerated()
	.filter { $1.splat(<) }
	.map { $0.offset + 1 }
print(correct.sum())

let divider1 = Packet(rawValue: "[[2]]")
let divider2 = Packet(rawValue: "[[6]]")
let allPackets = pairs.joined() + [divider1, divider2]

let sorted = allPackets.sorted { $0 < $1 }
let dividerIndices = sorted
	.enumerated()
	.filter { $1 == divider1 || $1 == divider2 }
	.map { $0.offset + 1 }
print(dividerIndices.product())

// ^ that's all it takes, but let's see what else we can do here…

// fun alternative approach that works completely without structure and could easily be adapted to not even need tokenization
struct FlatPacket: Parseable, Equatable {
	var tokens: [Token]
	
	init(from parser: inout Parser) {
		tokens = []
		while !parser.isDone {
			tokens.append(.init(from: &parser))
			_ = parser.tryConsume(",")
		}
	}
	
	static func < (lhs: Self, rhs: Self) -> Bool {
		var lhs = lhs.tokens[...]
		var rhs = rhs.tokens[...]
		
		func compareAsymmetric(_ value: Int, _ list: inout ArraySlice<Token>) -> Bool? {
			// first enter was already consumed to get us here
			let depth = list.prefix { $0 == .enter }.count + 1
			list.removeFirst(depth - 1)
			
			switch list.first! {
			case .leave:
				return false
			case .value(let other):
				guard value == other else { return value < other }
			case .enter:
				fatalError()
			}
			
			let popsMatch = list.prefix(depth).allSatisfy { $0 == .leave }
			guard popsMatch else { return true }
			// this line is literally never reached lmao:
			list.removeFirst(depth)
			
			return nil
		}
		
		while true {
			guard let l = lhs.popFirst() else { return true }
			guard let r = rhs.popFirst() else { return false }
			
			let result: Bool?
			switch (l, r) {
			case (.value(let l), .value(let r)):
				result = l == r ? nil : l < r
			case (.value(let l), .enter):
				result = compareAsymmetric(l, &rhs)
			case (.enter, .value(let r)):
				result = compareAsymmetric(r, &lhs).map(!)
			case (.leave, .leave), (.enter, .enter):
				result = nil
			case (.leave, .enter), (.leave, .value):
				return true
			case (.enter, .leave), (.value, .leave):
				return false
			}
			if let result { return result }
		}
	}
	
	enum Token: Parseable, Hashable {
		case enter
		case leave
		case value(Int)
		
		init(from parser: inout Parser) {
			if parser.tryConsume("[") {
				self = .enter
			} else if parser.tryConsume("]") {
				self = .leave
			} else {
				self = .value(parser.readInt())
			}
		}
	}
}
