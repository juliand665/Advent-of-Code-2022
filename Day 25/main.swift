import Foundation
import AoC_Helpers
import SimpleParser
import Algorithms
import Collections

let digits = Array("=-012")

let numbers = input().lines().map { $0
	.map { digits.onlyIndex(of: $0)! - 2 }
	.reduce(0) { $0 * 5 + $1 }
}

print(
	sequence(state: numbers.sum(), next: { rest -> Int? in
		guard rest != 0 else { return nil }
		rest += 2 // convert to regular base 5
		defer { rest /= 5 }
		return rest % 5
	})
	.reversed()
	.map({ digits[$0] })
	.asString()
) // 2-121-=10=200==2==21
