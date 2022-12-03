import Foundation
import AoC_Helpers
import SimpleParser
import Algorithms

func priority(of item: Character) -> Int {
	item.isLowercase ? item - "a" + 1 : item - "A" + 27
}

struct Rucksack: Parseable {
	let all: Substring
	let one, two: Substring
	
	init(from parser: inout Parser) {
		all = parser.consumeRest()
		one = all.prefix(all.count / 2)
		two = all.suffix(all.count / 2)
	}
	
	func sharedItem() -> Character {
		Set(one).intersection(two).onlyElement()!
	}
}

let rucksacks = input().lines().map(Rucksack.init)

print(rucksacks
	.map { priority(of: $0.sharedItem()) }
	.sum()
)

print(rucksacks
	.chunks(ofCount: 3)
	.map { $0
		.map(\.all)
		.intersectionOfElements()
		.onlyElement()!
	}
	.map(priority(of:))
	.sum()
)
