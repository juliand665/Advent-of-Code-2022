import Foundation
import AoC_Helpers
import SimpleParser
import Algorithms
import Collections

struct State {
	var monkeys: [Monkey]
	var isPart2: Bool
	
	init(monkeys: [Monkey], isPart2: Bool) {
		self.monkeys = monkeys
		self.isPart2 = isPart2
	}
	
	mutating func step() {
		for i in monkeys.indices {
			var monkey = monkeys[i]
			monkey.step(state: &self)
			monkeys[i] = monkey
		}
	}
	
	func monkeyBusiness() -> Int {
		monkeys.map(\.inspections).max(count: 2).product()
	}
}

struct Monkey: Parseable {
	var items: Deque<Int>
	var operation: (Int) -> Int
	var testDivisor: Int
	var trueDest: Int
	var falseDest: Int
	
	var inspections = 0
	
	init(from parser: inout Parser) {
		parser.consumeLine()
		items = .init(parser.line().auto())
		
		var opParser = parser.line()
		opParser.consume(through: "=")
		opParser.consume(" old ")
		if opParser.tryConsume("* old") {
			operation = { $0 * $0 }
		} else if opParser.tryConsume("* ") {
			let const = opParser.readInt()
			operation = { $0 * const }
		} else if opParser.tryConsume("+ ") {
			let const = opParser.readInt()
			operation = { $0 + const }
		} else {
			fatalError(opParser.auto())
		}
		assert(opParser.isDone)
		
		(testDivisor, trueDest, falseDest) = parser.auto()
	}
}

let monkeys = input().lineGroups().map(Monkey.init)
let base = monkeys.map(\.testDivisor).product()

extension Monkey {
	mutating func step(state: inout State) {
		while let item = items.popFirst() {
			inspections += 1
			
			let result = operation(item)
			let worry = state.isPart2 ? result % base : result / 3
			let dest = (worry % testDivisor == 0) ? trueDest : falseDest
			state.monkeys[dest].items.append(worry)
		}
	}
}

var state1 = State(monkeys: monkeys, isPart2: false)
for _ in 0..<20 {
	state1.step()
}
print(state1.monkeyBusiness())

var state2 = State(monkeys: monkeys, isPart2: true)
for _ in 0..<10_000 {
	state2.step()
}
print(state2.monkeyBusiness())
