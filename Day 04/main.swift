import Foundation
import AoC_Helpers
import SimpleParser
import Algorithms

struct Assignment: Parseable {
	var section1, section2: ClosedRange<Int>
	
	init(from parser: inout Parser) {
		(section1, section2) = parser.readValues()
	}
	
	var isRidiculous: Bool {
		section1.contains(section2) || section2.contains(section1)
	}
	
	var hasOverlap: Bool {
		section1.overlaps(section2)
	}
}

let assignments = input().lines().map(Assignment.init)
print(assignments.count(where: \.isRidiculous))
print(assignments.count(where: \.hasOverlap))
