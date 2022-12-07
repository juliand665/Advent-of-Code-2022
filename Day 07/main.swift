import Foundation
import AoC_Helpers
import SimpleParser
import Algorithms

struct File {
	var name: String
	var size: Int
}

final class Folder {
	var name: String
	var parent: Folder?
	var subfolders: [Folder] = []
	var files: [File] = []
	
	var totalSize: Int {
		files.lazy.map(\.size).sum()
		+ subfolders.lazy.map(\.totalSize).sum()
	}
	
	init(name: String, parent: Folder?) {
		self.name = name
		self.parent = parent
	}
	
	func sumOfSmallFolderSizes() -> Int {
		(totalSize <= 100_000 ? totalSize : 0)
		+ subfolders.map { $0.sumOfSmallFolderSizes() }.sum()
	}
	
	func smallestFolderToDelete(toFreeUp: Int) -> Int {
		subfolders.lazy
			.map { $0.smallestFolderToDelete(toFreeUp: toFreeUp) }
			.reduce(totalSize >= toFreeUp ? totalSize : .max, min)
	}
}

let root = Folder(name: "/", parent: nil)
var current = root
for line in input().lines().dropFirst() {
	var parser = Parser(reading: line)
	if parser.tryConsume("$ ") {
		if parser.tryConsume("cd ") {
			let target = parser.consumeRest()
			if target == ".." {
				current = current.parent!
			} else {
				current = current.subfolders.first { $0.name == target }!
			}
		} else if parser.tryConsume("ls") {} // non-command lines are already read as ls entries
	} else {
		if parser.tryConsume("dir ") {
			let folder = Folder(name: String(parser.consumeRest()), parent: current)
			current.subfolders.append(folder)
		} else {
			let size = parser.readInt()
			parser.consume(" ")
			let file = File(name: String(parser.consumeRest()), size: size)
			current.files.append(file)
		}
	}
}

print(root.sumOfSmallFolderSizes())
let toFreeUp = 30_000_000 - (70_000_000 - root.totalSize)
print(root.smallestFolderToDelete(toFreeUp: toFreeUp))
