// =============================================================
//  Assignment 2 · Working with Collections in Swift
//  Rule: NO loops (for/while) and NO if/else.
// =============================================================

// MARK: - Easy

// 1. Array creation and access
let fruits = ["apple", "banana", "cherry", "mango", "kiwi"]
print("Third fruit:", fruits[2])           // индексы начинаются с 0 → [2] это третий

// 2. Set creation and manipulation
var favoriteNumbers: Set<Int> = [3, 7, 13]
favoriteNumbers.insert(42)                 // у Set нет append, есть insert
print("Updated set:", favoriteNumbers)     // порядок в Set не гарантирован

// 3. Dictionary creation and access
let languages: [String: Int] = ["Swift": 2014, "Python": 1991, "Java": 1995]
print("Swift release year:", languages["Swift"] ?? 0)   // словарь возвращает Optional → ?? даёт значение по умолчанию

// 4. Array element update
var colors = ["red", "green", "blue", "yellow"]
colors[1] = "purple"
print("Updated colors:", colors)

// MARK: - Medium

// 1. Set intersection
let setA: Set = [1, 2, 3, 4]
let setB: Set = [3, 4, 5, 6]
print("Intersection:", setA.intersection(setB))   // общие элементы → {3, 4}

// 2. Dictionary update
var scores = ["Aliya": 85, "Bekzat": 72, "Dana": 90]
scores.updateValue(95, forKey: "Bekzat")         // или scores["Bekzat"] = 95
print("Updated scores:", scores)

// 3. Array merge
let firstArray = ["apple", "banana"]
let secondArray = ["cherry", "date"]
let merged = firstArray + secondArray
print("Merged:", merged)

// MARK: - Hard

// 1. Dictionary key addition
var populations = ["Kazakhstan": 20_000_000, "Japan": 124_000_000, "France": 68_000_000]
populations["Uzbekistan"] = 36_000_000          // нового ключа не было → он добавляется
print("Populations:", populations)

// 2. Set union and subtract
let pets1: Set = ["cat", "dog"]
let pets2: Set = ["dog", "mouse"]
let unionSet = pets1.union(pets2)               // {"cat", "dog", "mouse"}
let finalSet = unionSet.subtracting(pets2)      // {"cat"}
print("Union:", unionSet)
print("Union minus second set:", finalSet)

// 3. Nested collection
let studentGrades: [String: [Int]] = [
    "Aliya":  [90, 85, 77],
    "Bekzat": [60, 88, 95],
    "Dana":   [100, 92, 81]
]
print("Bekzat's second grade:", studentGrades["Bekzat"]?[1] ?? 0)  // ?. — optional chaining
