import Foundation
import AoC_Helpers
import SimpleParser
import Algorithms

var register = 1
var strengths: [Int] = []
var cycleNumber = 0
var screen = Matrix(width: 40, height: 6, repeating: false)

func completeCycle() {
	let x = cycleNumber % 40
	screen[x, cycleNumber / 40] = abs(x - register) <= 1
	cycleNumber += 1
	if cycleNumber % 40 == 20 {
		strengths.append(register * cycleNumber)
	}
}

for line in input().lines() {
	var parser = Parser(reading: line)
	switch parser.readWord() {
	case "noop":
		completeCycle()
	case "addx":
		parser.consume(" ")
		let v = parser.readInt()
		completeCycle()
		completeCycle()
		register += v
	case let other:
		fatalError(String(other))
	}
}

print(strengths.sum())
print(screen.binaryImage())
