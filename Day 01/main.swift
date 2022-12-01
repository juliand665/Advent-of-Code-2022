import Foundation
import AoC_Helpers

let invs = input().lines().split(separator: "")
let calories = invs.map { $0.asInts().sum() }
print(calories.max()!)
print(calories.sorted().suffix(3).sum())
