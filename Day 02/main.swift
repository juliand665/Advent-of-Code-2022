import Foundation
import AoC_Helpers
import SimpleParser

let abc = Array("ABC")
let xyz = Array("XYZ")

struct Round: Parseable {
	var lhs, rhs: Int
	
	init(from parser: inout Parser) {
		lhs = abc.firstIndex(of: parser.consumeNext())!
		parser.consume(" ")
		rhs = xyz.firstIndex(of: parser.consumeNext())!
	}
	
	var winner: Int {
		lhs == rhs ? 0 : (lhs + 1) % 3 == rhs ? 1 : -1
	}
	
	var score1: Int {
		3 * (winner + 1) + (rhs + 1)
	}
	
	var score2: Int {
		3 * rhs + ((lhs + rhs + 2) % 3 + 1)
	}
}

let rounds = input().lines().map(Round.init)
print(rounds.map(\.score1).sum())
print(rounds.map(\.score2).sum())
