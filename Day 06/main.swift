import Foundation
import AoC_Helpers
import SimpleParser
import Algorithms

let buffer = input()

func findStartOfPacket(markerLength: Int) -> Int {
	Array(buffer)
		.windows(ofCount: markerLength)
		.first { Set($0).count == markerLength }!
		.endIndex
}

print(findStartOfPacket(markerLength: 4))
print(findStartOfPacket(markerLength: 14))
