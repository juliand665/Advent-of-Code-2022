import Foundation
import AoC_Helpers
import SimpleParser
import Algorithms

let forest = Matrix(digitsOf: input().lines())

let positions = forest.positionMatrix()
let lines = chain(
	chain(positions.rows, positions.rows.map { $0.reversed() }),
	chain(positions.columns(), positions.columns().map { $0.reversed() })
)

var visibleTrees: Set<Vector2> = []
for line in lines {
	var maxHeight = -1
	for position in line {
		if forest[position] > maxHeight {
			visibleTrees.insert(position)
			maxHeight = forest[position]
		}
	}
}
print(visibleTrees.count)

var scenicScores = Matrix(width: forest.width, height: forest.height, repeating: 1)
for line in lines {
	var scores = Array(repeating: 0, count: 10)
	for position in line {
		let height = forest[position]
		scenicScores[position] *= scores[height]
		for i in scores.indices {
			scores[i] = i <= height ? 1 : scores[i] + 1
		}
	}
}
print(scenicScores.max()!)
