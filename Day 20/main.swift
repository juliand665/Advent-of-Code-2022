import Foundation
import AoC_Helpers
import SimpleParser
import Algorithms
import Collections

let numbers = input().lines().map { Int($0)! }

func wrap(_ index: Int) -> Int {
	index %% numbers.count
}

func runSim(rounds: Int = 1, factor: Int = 1) -> Int {
	let numbers = numbers.map { $0 * factor }
	var indices = Array(numbers.indices)
	for _ in 0..<rounds {
		for (index, num) in numbers.indexed() {
			let smallNum = num % (numbers.count - 1)
			let pos = indices.firstIndex(of: index)!
			let dir = smallNum.signum()
			let target = wrap(pos + smallNum)
			var curr = pos
			while curr != target {
				let next = wrap(curr + dir)
				indices.swapAt(curr, next)
				curr = next
			}
		}
	}
	
	let anchor = indices.onlyIndex(of: numbers.onlyIndex(of: 0)!)!
	return (1...3).map { numbers[indices[wrapping: anchor + $0 * 1000]] }.sum()
}

measureTime {
	print(runSim()) // 14888
}

measureTime {
	print(runSim(rounds: 10, factor: 811589153)) // 3760092545849
}

