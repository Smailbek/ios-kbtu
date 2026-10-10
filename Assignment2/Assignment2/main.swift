let fruits = ["apple", "banana", "cherry", "mango", "kiwi"]
print("Third fruit:", fruits[2])


var favoriteNumbers: Set<Int> = [3, 7, 13]
favoriteNumbers.insert(42)
print("Updated set:", favoriteNumbers)


let languages: [String: Int] = ["Swift": 2014, "Python": 1991, "Java": 1995]
print("Swift release year:", languages["Swift"] ?? 0)

var colors = ["red", "green", "blue", "yellow"]
colors[1] = "purple"
print("Updated colors:", colors)


let setA: Set = [1, 2, 3, 4]
let setB: Set = [3, 4, 5, 6]
print("Intersection:", setA.intersection(setB))


var scores = ["Aliya": 85, "Bekzat": 72, "Dana": 90]
scores.updateValue(95, forKey: "Bekzat")
print("Updated scores:", scores)


let firstArray = ["apple", "banana"]
let secondArray = ["cherry", "date"]
let merged = firstArray + secondArray
print("Merged:", merged)



var populations = ["Kazakhstan": 20_000_000, "Japan": 124_000_000, "France": 68_000_000]
populations["Uzbekistan"] = 36_000_000
print("Populations:", populations)


let pets1: Set = ["cat", "dog"]
let pets2: Set = ["dog", "mouse"]
let unionSet = pets1.union(pets2)
let finalSet = unionSet.subtracting(pets2)
print("Union:", unionSet)
print("Union minus second set:", finalSet)


let studentGrades: [String: [Int]] = [
    "Aliya":  [90, 85, 77],
    "Bekzat": [60, 88, 95],
    "Dana":   [100, 92, 81]
]
print("Bekzat's second grade:", studentGrades["Bekzat"]?[1] ?? 0)
