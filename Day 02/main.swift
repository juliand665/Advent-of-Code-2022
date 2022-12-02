import Foundation
import AoC_Helpers
import SimpleParser

struct Round: Parseable {
	var lhs, rhs: Int
	
	init(from parser: inout Parser) {
		lhs = parser.consumeNext() - "A"
		parser.consume(" ")
		rhs = parser.consumeNext() - "X"
	}
	
	var score1: Int {
		let winner = lhs == rhs ? 0 : (lhs + 1) % 3 == rhs ? 1 : -1
		return 3 * (winner + 1) + (rhs + 1)
	}
	
	var score2: Int {
		3 * rhs + ((lhs + rhs + 2) % 3 + 1)
	}
}

let rounds = input().lines().map(Round.init)
print(rounds.map(\.score1).sum())
print(rounds.map(\.score2).sum())
