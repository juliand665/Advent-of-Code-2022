import Foundation
import AoC_Helpers
import SimpleParser
import Algorithms
import Collections

enum Op: String, Hashable {
	case add = "+"
	case sub = "-"
	case mul = "*"
	case div = "/"
	
	func evaluate(_ lhs: Int, _ rhs: Int) -> Int {
		switch self {
		case .add: return lhs + rhs
		case .sub: return lhs - rhs
		case .mul: return lhs * rhs
		case .div: return lhs / rhs
		}
	}
	
	var opposite: Self {
		switch self {
		case .add: return .sub
		case .sub: return .add
		case .mul: return .div
		case .div: return .mul
		}
	}
	
	var isReflexive: Bool {
		switch self {
		case .add: return true
		case .sub: return false
		case .mul: return true
		case .div: return false
		}
	}
}

struct Monkey: Parseable {
	var id: String
	var output: Output
	
	init(from parser: inout Parser) {
		id = String(parser.consumeNext(4))
		parser.consume(": ")
		if parser.next!.isNumber {
			output = .constant(parser.readInt())
		} else {
			let (l, op, r) = parser.consumeRest().components(separatedBy: " ").extract()
			output = .operation(l, r, Op(rawValue: op)!)
		}
	}
	
	var lhs: String? {
		guard case .operation(let lhs, _, _) = output else { return nil }
		return lhs
	}
	
	var rhs: String? {
		guard case .operation(_, let rhs, _) = output else { return nil }
		return rhs
	}
	
	enum Output {
		case constant(Int)
		case operation(String, String, Op)
	}
}

let monkeys = input().lines().map(Monkey.init)
let byID = Dictionary(uniqueKeysWithValues: monkeys.map { ($0.id, $0) })
let byLHS = Dictionary(uniqueKeysWithValues: monkeys.compactMap { m in m.lhs.map { ($0, m) } })
let byRHS = Dictionary(uniqueKeysWithValues: monkeys.compactMap { m in m.rhs.map { ($0, m) } })
let tainted = Set(sequence(first: "humn") { (byLHS[$0] ?? byRHS[$0])?.id })

func evaluate(monkey: String) -> Int {
	switch byID[monkey]!.output {
	case .constant(let value):
		return value
	case .operation(let lhs, let rhs, let op):
		return op.evaluate(evaluate(monkey: lhs), evaluate(monkey: rhs))
	}
}

print(evaluate(monkey: "root")) // 43699799094202

func makeEqual(root: String, target: Int) -> Int {
	guard root != "humn" else {
		return target
	}
	
	switch byID[root]!.output {
	case .constant:
		fatalError()
	case .operation(let lhs, let rhs, let op):
		let (variable, constant) = tainted.contains(lhs) ? (lhs, rhs) : (rhs, lhs)
		let other = evaluate(monkey: constant)
		
		guard root != "root" else { // i wish they'd just had us make root = 0
			return makeEqual(root: variable, target: other)
		}
		
		let newTarget = op.isReflexive
		? op.opposite.evaluate(target, other)
		: (variable == lhs ? op.opposite : op).evaluate(other, target)
		
		return makeEqual(root: variable, target: newTarget)
	}
}

measureTime {
	print(makeEqual(root: "root", target: 0)) // 3375719472770
}

// (x - 2) * 5 = 15
// x - 2 = 15 / 5 = 3
// x = 2 + 3 = 5

// (2 - x) * 5 = 15
// 2 - x = 15 / 5 = 3
// x = 2 - 3 = -1

// (x + 2) * 5 = 15
// x + 2 = 15 / 5 = 3
// x = 3 - 2 = 1

// (2 + x) * 5 = 15
// 2 + x = 15 / 5 = 3
// x = 3 - 2 = -1
