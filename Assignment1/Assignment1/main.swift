// =============================================================
//  Assignment 1 · Your Life Story in Swift
//  Student: Sagdi Smailbek
// =============================================================

// MARK: Step 1 · Personal information
let firstName: String = "Sagdi"        // String — текст
let lastName: String = "Smailbek"
let birthYear: Int = 2005              // Int — целое число
let currentYear: Int = 2026            // let = константа, менять нельзя

// Bonus Challenge: возраст считаем, а не вписываем руками
let age: Int = currentYear - birthYear

var isStudent: Bool = true             // Bool — true / false
var height: Double = 1.95              // Double — дробное число (метры)
var city: String = "Almaty"
var university: String = "KBTU"

// MARK: Step 2 · Hobbies and interests
var hobby: String = "football ⚽️"
var numberOfHobbies: Int = 3
var favoriteNumber: Int = 7
var isHobbyCreative: Bool = false
var favoriteFood: String = "плов"

// MARK: Bonus · emoji as values and as variable names
let 🎯 = "become a professional iOS developer"
var futureGoals: String = "In the future, I want to \(🎯) 🚀"
let 🍎 = "Swift"

// MARK: Step 3 · Summary with string interpolation \( )
let studentText = isStudent ? "I am currently a student at \(university)." : "I am not a student."
let creativeText = isHobbyCreative ? "which is a creative hobby" : "which is a sport, not a creative hobby"

var lifeStory = "My name is \(firstName) \(lastName). I am \(age) years old, born in \(birthYear). "
lifeStory += "I live in \(city) and I am \(height) m tall. \(studentText) "
lifeStory += "I enjoy \(hobby), \(creativeText). I have \(numberOfHobbies) hobbies in total, "
lifeStory += "and my favorite number is \(favoriteNumber). My favorite food is \(favoriteFood). "
lifeStory += "I am learning \(🍎). "
lifeStory += futureGoals          // Bonus: append futureGoals

// MARK: Step 4 · Print
print(lifeStory)

