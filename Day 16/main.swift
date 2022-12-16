import Foundation
import AoC_Helpers
import SimpleParser
import Algorithms
import Collections

/*
 My algorithm for today's problem initially took some 30s for part 2, so I went and performed a variety of optimizations, which is why this file is so long lol.
 Fundamentally, the algorithm relies on ignoring valves with zero value, instead folding them into distance measurements between the nonzero valves.
 Thus, when exploring the solution space, you don't need to decide whether to turn on a valve or leave it, since the only reason you'd even go to a valve is to turn it on—all valves are connected, just with different path lengths.
 The optimizations that make this faster include:
 
 - Turning the String IDs into auto-incremented int IDs
 - Using arrays to represent per-valve data rather than dictionaries
 - Using a single integer as bitmask to track which valves have been opened, rather than an array or set.
 - Sorting the valve IDs so all the nonzero valves (the actually interesting ones) precede the zero valves, so we can just use the range 0..<nonZeroCount.
 - Not actually using the `Valve` struct later on by computing the array of flow rates for each valve (in addition to the aforementioned precomputed distances).
 */

// convert string IDs to auto-incremented int IDs
var rawIDs: [String] = []
func getID(_ raw: String) -> Int {
	if let index = rawIDs.firstIndex(of: raw) {
		return index
	} else {
		rawIDs.append(raw)
		return rawIDs.count - 1
	}
}

struct Valve: Parseable {
	var id: Int
	var flowRate: Int
	var neighbors: [Int]
	
	init(from parser: inout Parser) {
		parser.consume("Valve ")
		id = getID(String(parser.consume(upTo: " ")!))
		_ = parser.consume(through: "=")!
		flowRate = parser.readInt()
		// why
		if !parser.tryConsume("; tunnels lead to valves ") {
			parser.consume("; tunnel leads to valve ")
		}
		neighbors = parser.consumeRest().components(separatedBy: ", ").map(getID)
	}
}

// BFS
func findDistances<T: Hashable>(to target: T, count: Int, connections: (T) -> [T]) -> [T: Int] {
	var distances: [T: Int] = [target: 0]
	var toExplore: Set<T> = [target]
	var distance = 0
	while distances.count < count {
		distance += 1
		toExplore = Set(toExplore.lazy.flatMap(connections)).subtracting(distances.keys)
		for found in toExplore {
			distances[found] = distance
		}
	}
	return distances
}

typealias ValveSet = BitMask<UInt64>

// make sure nonzero valve IDs precede zero valve IDs
let nonZeroIDs = input().lines()
	.filter { !$0.contains("flow rate=0;") }
	.map { String($0.trimmingPrefix("Valve ").prefix(2)) }
for id in nonZeroIDs {
	_ = getID(id)
}

let valves = input().lines().map(Valve.init).sorted(on: \.id)
let start = getID("AA")
let flowRates = valves.map(\.flowRate)
let nonZeroCount = flowRates.count { $0 > 0 }

let distances = Matrix(valves.map {
	findDistances(to: $0.id, count: valves.count) { valves[$0].neighbors }
		.asArray()
})

func bestValue(startingFrom source: Int, timeLeft: Int, opened: ValveSet) -> Int {
	(0..<nonZeroCount)
		.lazy
		.compactMap { candidate in
			guard !opened.contains(candidate) else { return nil }
			let timeLeft = timeLeft - distances[source, candidate] - 1
			guard timeLeft > 0 else { return nil }
			let value = flowRates[candidate] * timeLeft
			return value + bestValue(
				startingFrom: candidate,
				timeLeft: timeLeft,
				opened: opened.inserting(candidate)
			)
		}
		.max() ?? 0
}

measureTime {
	print(bestValue(startingFrom: start, timeLeft: 30, opened: []))
}

// this takes 3s or so in release mode. …it's fine
func bestValue(startingFrom sources: (Int, Int), timesLeft: (Int, Int), opened: ValveSet) -> Int {
	(0..<nonZeroCount)
		.lazy
		.compactMap { candidate in
			guard !opened.contains(candidate) else { return nil }
			let timeLeft = timesLeft.0 - distances[sources.0, candidate] - 1
			guard timeLeft > 0 else { return nil }
			let value = flowRates[candidate] * timeLeft
			let isNext = timeLeft >= timesLeft.1
			return value + bestValue(
				startingFrom: isNext ? (candidate, sources.1) : (sources.1, candidate),
				timesLeft: isNext ? (timeLeft, timesLeft.1) : (timesLeft.1, timeLeft),
				opened: opened.inserting(candidate)
			)
		}
		.max() ?? 0
}

measureTime {
	print(bestValue(startingFrom: (start, start), timesLeft: (26, 26), opened: []))
}
