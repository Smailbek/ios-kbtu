let firstName: String = "Sagdi"
let lastName: String = "Smailbek"
let birthYear: Int = 2005
let currentYear: Int = 2026

let age: Int = currentYear - birthYear

var isStudent: Bool = true
var height: Double = 1.95
var city: String = "Almaty"
var university: String = "KBTU"

var hobby: String = "football ⚽️"
var numberOfHobbies: Int = 3
var favoriteNumber: Int = 7
var isHobbyCreative: Bool = false
var favoriteFood: String = "плов"

let 🎯 = "become a professional iOS developer"
var futureGoals: String = "In the future, I want to \(🎯) 🚀"
let 🍎 = "Swift"

let studentText = isStudent ? "I am currently a student at \(university)." : "I am not a student."
let creativeText = isHobbyCreative ? "which is a creative hobby" : "which is a sport, not a creative hobby"

var lifeStory = "My name is \(firstName) \(lastName). I am \(age) years old, born in \(birthYear). "
lifeStory += "I live in \(city) and I am \(height) m tall. \(studentText) "
lifeStory += "I enjoy \(hobby), \(creativeText). I have \(numberOfHobbies) hobbies in total, "
lifeStory += "and my favorite number is \(favoriteNumber). My favorite food is \(favoriteFood). "
lifeStory += "I am learning \(🍎). "
lifeStory += futureGoals

print(lifeStory)

