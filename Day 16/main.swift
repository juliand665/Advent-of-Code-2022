import Foundation
import AoC_Helpers
import SimpleParser
import Algorithms
import Collections

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
		if !parser.tryConsume("; tunnels lead to valves ") {
			parser.consume("; tunnel leads to valve ")
		}
		neighbors = parser.consumeRest().components(separatedBy: ", ").map(getID)
	}
}

func distances<T: Hashable>(to target: T, count: Int, connections: (T) -> [T]) -> [T: Int] {
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

let allValves = input().lines().map(Valve.init)
let valves = Dictionary(uniqueKeysWithValues: allValves.map { ($0.id, $0) })
let nonZero = allValves.filter { $0.flowRate > 0 }

let allDistances = valves.mapValues { distances(to: $0.id, count: valves.count) { valves[$0]!.neighbors } }

func bestValue(startingFrom source: Int, timeLeft: Int, opened: [Int]) -> Int {
	let dists = allDistances[source]!
	let candidates = nonZero.filter { !opened.contains($0.id) && dists[$0.id]! + 1 < timeLeft }
	return candidates.lazy.map { candidate in
		let d = dists[candidate.id]!
		let time = timeLeft - d - 1
		let value = candidate.flowRate * time
		return value + bestValue(startingFrom: candidate.id, timeLeft: time, opened: opened + [candidate.id])
	}.max() ?? 0
}

measureTime {
	print(bestValue(startingFrom: getID("AA"), timeLeft: 30, opened: []))
}

// this takes a solid 10s or so in release mode but it's fine
func bestValue(startingFrom sources: (Int, Int), timeBetween: Int, timeLeft: Int, opened: [Int]) -> Int {
	let dists = allDistances[sources.0]!
	let candidates = nonZero.filter { !opened.contains($0.id) && dists[$0.id]! + 1 < timeLeft }
	return candidates.lazy.map { candidate in
		let d = dists[candidate.id]!
		let time = timeLeft - d - 1
		let value = candidate.flowRate * time
		let deltaT = d + 1 - timeBetween
		if deltaT < 0 {
			return value + bestValue(startingFrom: (candidate.id, sources.1), timeBetween: -deltaT, timeLeft: time, opened: opened + [candidate.id])
		} else {
			return value + bestValue(startingFrom: (sources.1, candidate.id), timeBetween: deltaT, timeLeft: timeLeft - timeBetween, opened: opened + [candidate.id])
		}
	}.max() ?? 0
}

measureTime {
	print(bestValue(startingFrom: (getID("AA"), getID("AA")), timeBetween: 0, timeLeft: 26, opened: []))
}
