import Foundation
import AoC_Helpers
import SimpleParser
import Algorithms
import Collections
import HandyOperators

final class Blueprint: Parseable {
	var number: Int
	var oreCost: Int
	var clayCost: Int
	var obsidianCost: (Int, Int) // ore, clay
	var geodeCost: (Int, Int) // ore, obsidian
	var maxOreProd: Int
	
	init(from parser: inout Parser) {
		(number, oreCost, clayCost, obsidianCost, geodeCost) = parser.ints().splat {
			($0, $1, $2, ($3, $4), ($5, $6))
		}
		// not worth producing any more ore than this
		maxOreProd = [oreCost, clayCost, obsidianCost.0, geodeCost.0].max()!
	}
	
	var best = 0
	var explored: Set<State> = []
	
	func explore(from state: State) {
		guard explored.insert(state).inserted else { return }
		best = max(best, state.finalGeodes)
		
		guard state.timeLeft > 1 else { return }
		for nextChoice in Choice.allCases.reversed() {
			guard state.timeLeft > 2 || nextChoice == .geode else { return }
			guard let new = apply(nextChoice, to: state) else { continue }
			explore(from: new)
		}
	}
	
	func apply(_ choice: Choice, to start: State) -> State? {
		var state = start
		
		switch choice {
		case .ore:
			guard state.oreProd < maxOreProd else { return nil }
			let turns = 1 + max(0, oreCost - state.ore + state.oreProd - 1) / state.oreProd
			state.step(count: turns)
			state.ore -= oreCost
			state.oreProd += 1
		case .clay:
			guard state.clayProd < obsidianCost.1 else { return nil }
			let turns = 1 + max(0, clayCost - state.ore + state.oreProd - 1) / state.oreProd
			state.step(count: turns)
			state.ore -= clayCost
			state.clayProd += 1
		case .obsidian:
			guard state.clayProd > 0 else { return nil }
			guard state.obsidianProd < geodeCost.1 else { return nil }
			let turns = 1 + max(
				max(0, obsidianCost.0 - state.ore + state.oreProd - 1) / state.oreProd,
				max(0, obsidianCost.1 - state.clay + state.clayProd - 1) / state.clayProd
			)
			state.step(count: turns)
			state.ore -= obsidianCost.0
			state.clay -= obsidianCost.1
			state.obsidianProd += 1
		case .geode:
			guard state.obsidianProd > 0 else { return nil }
			let turns = 1 + max(
				max(0, geodeCost.0 - state.ore + state.oreProd - 1) / state.oreProd,
				max(0, geodeCost.1 - state.obsidian + state.obsidianProd - 1) / state.obsidianProd
			)
			state.step(count: turns)
			state.ore -= geodeCost.0
			state.obsidian -= geodeCost.1
			state.geodeProd += 1
		}
		
		return state.timeLeft >= 0 ? state : nil
	}
}

enum Choice: Hashable, CaseIterable {
	case ore
	case clay
	case obsidian
	case geode
}

struct State: Hashable {
	var timeLeft: Int
	var oreProd = 1
	var ore = 0
	var clayProd = 0
	var clay = 0
	var obsidianProd = 0
	var obsidian = 0
	var geodeProd = 0
	var geodes = 0
	
	mutating func step(count: Int = 1) {
		timeLeft -= count
		ore += oreProd * count
		clay += clayProd * count
		obsidian += obsidianProd * count
		geodes += geodeProd * count
	}
	
	var finalGeodes: Int {
		geodes + geodeProd * timeLeft
	}
}

measureTime {
	print(input().lines().map(Blueprint.init).map { bp -> Int in
		bp.explore(from: .init(timeLeft: 24))
		print(bp.best, bp.explored.count)
		bp.explored = []
		return bp.best * bp.number
	}.sum())
}

print()

let blueprints = input().lines().map(Blueprint.init).prefix(3)

for blueprint in blueprints {
	measureTime {
		blueprint.explore(from: .init(timeLeft: 32))
		print(blueprint.best, blueprint.explored.count)
	}
}

print(blueprints.map(\.best).product())
