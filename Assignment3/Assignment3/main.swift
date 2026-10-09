
// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================


// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · Decoding Telemetry

// 1.1
// One guard let with several comma-separated conditions:
// all of them must pass, otherwise we leave the function with nil.
func parseReading(_ raw: String) -> Reading? {
    guard let (sensor, valueText) = splitOnce(raw, by: ":"),
          sensor.isEmpty == false,
          let value = Int(valueText),
          value >= 0 || sensor == "TEMP"
    else {
        return nil
    }
    return (sensor: sensor, value: value)
}

print(parseReading("O2:87") as Any)      // Optional((sensor: "O2", value: 87))
print(parseReading("TEMP:-12") as Any)   // Optional((sensor: "TEMP", value: -12))
print(parseReading("RAD:-1") as Any)     // nil
print(parseReading(":55") as Any)        // nil

// 1.2
func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var valid: [Reading] = []
    var invalidCount = 0
    for line in lines {
        if let reading = parseReading(line) {
            valid.append(reading)
        } else {
            invalidCount += 1
        }
    }
    return (valid: valid, invalidCount: invalidCount)
}

let parsed = parseLog(rawLog)
print("Valid readings: \(parsed.valid.count), corrupted: \(parsed.invalidCount)")
print(parseLog(["O2:1", "bad"]))         // second test call

let A = parsed.invalidCount
print("A =", A)


// MARK: Level 2 · Analysis

// 2.1 · our own `filter`
func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var result: [Reading] = []
    for reading in readings {
        if isIncluded(reading) {
            result.append(reading)
        }
    }
    return result
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []
    for reading in readings {
        result.append(reading.value)
    }
    return result
}

// trailing closure + $0
let o2Readings = select(parsed.valid) { $0.sensor == "O2" }
print("O2 readings:", o2Readings)
print("O2 values:", values(of: o2Readings))
print("TEMP readings:", select(parsed.valid) { $0.sensor == "TEMP" })
print("All values:", values(of: parsed.valid))

// 2.2
func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard let first = values.first else { return nil }   // empty array -> nil, no crash
    var minValue = first
    var maxValue = first
    var sum = 0
    for value in values {
        if value < minValue { minValue = value }
        if value > maxValue { maxValue = value }
        sum += value
    }
    return (min: minValue, max: maxValue, average: Double(sum) / Double(values.count))
}

// Variadic version: one line, no `return`, calls the first one (no duplicated logic)
func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

print(stats(3, 8, 1) as Any)   // (min: 1, max: 8, average: 4.0)
print(stats() as Any)          // nil

let o2Stats = stats(of: values(of: o2Readings))
let B = Int(o2Stats?.average ?? 0)
print("B =", B)

// 2.3 · The Closure Ladder (descending by value)
let valid = parsed.valid

// 1. Full syntax: types + return
let sort1 = valid.sorted(by: { (a: Reading, b: Reading) -> Bool in
    return a.value > b.value
})
// 2. Types inferred from context
let sort2 = valid.sorted(by: { a, b in return a.value > b.value })
// 3. Implicit return (single expression)
let sort3 = valid.sorted(by: { a, b in a.value > b.value })
// 4. Shorthand argument names
let sort4 = valid.sorted(by: { $0.value > $1.value })
// 5. Trailing closure
let sort5 = valid.sorted { $0.value > $1.value }

// Tuples are not Equatable, so we compare element by element ourselves
func sameOrder(_ x: [Reading], _ y: [Reading]) -> Bool {
    guard x.count == y.count else { return false }
    for i in 0..<x.count {
        if x[i].sensor != y[i].sensor || x[i].value != y[i].value {
            return false
        }
    }
    return true
}

let allSortsMatch = sameOrder(sort1, sort2) && sameOrder(sort1, sort3)
                 && sameOrder(sort1, sort4) && sameOrder(sort1, sort5)
print("Sorted:", sort1)
print("All five sorts match:", allSortsMatch)


// MARK: Level 3 · Temperature Stabilization

// 3.1
func heatUp(_ t: Int) -> Int { t + 5 }
func coolDown(_ t: Int) -> Int { t - 3 }
func hold(_ t: Int) -> Int { t }

func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 { return heatUp }
    if temp > 24 { return coolDown }
    return hold
}

print(chooseProtocol(for: 10)(10))   // 15 (heatUp)
print(chooseProtocol(for: 30)(30))   // 27 (coolDown)
print(chooseProtocol(for: 20)(20))   // 20 (hold)

// 3.2
func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    var temp = start
    var steps = 0
    while (18...24).contains(temp) == false && steps < maxSteps {
        let action = chooseProtocol(for: temp)
        temp = action(temp)
        steps += 1
    }
    return (finalTemp: temp, steps: steps, isStable: (18...24).contains(temp))
}

print(runUntilStable(from: 31))                  // (22, 3, true)
print(runUntilStable(from: -100, maxSteps: 5))   // (-75, 5, false)

let tempStats = stats(of: values(of: select(valid) { $0.sensor == "TEMP" }))
let lowestTemp = tempStats?.min ?? 0
let C = runUntilStable(from: lowestTemp).steps
print("Lowest TEMP = \(lowestTemp), C =", C)


// MARK: Level 4 · The Crew

// 4.1 · one line, optional chaining
func oxygenLevel(of member: CrewMember) -> Int? {
    member.module?.oxygenTank?.level
}

print(oxygenLevel(of: crew[0]) as Any)   // Timur  -> Optional(40)
print(oxygenLevel(of: crew[3]) as Any)   // Nurlan -> nil

// 4.2
func status(of member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no data (\(member.module?.name ?? "open space"))"
    }
    return "\(member.name): \(level)% \(level < 20 ? "CRITICAL" : "OK")"
}

for member in crew {
    print(status(of: member))
}

// 4.3
@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    guard amount > 0 else { return 0 }
    let freeSpace = max(0, 100 - target)
    let actual = min(amount, source, freeSpace)
    source -= actual
    target += actual
    return actual
}

// test calls on plain variables
var t1 = 50, t2 = 90
print("moved:", transferOxygen(from: &t1, to: &t2, amount: 30), t1, t2)  // 10, 40, 100
print("moved:", transferOxygen(from: &t1, to: &t2, amount: -5), t1, t2)  // 0

// Lab -> Hab, tanks are optional, no `!`
if let labTank = lab.oxygenTank, let habTank = hab.oxygenTank {
    let moved = transferOxygen(from: &labTank.level, to: &habTank.level, amount: 30)
    print("Transferred \(moved): Lab \(labTank.level), Hab \(habTank.level)")
}

let D = hab.oxygenTank?.level ?? 0
print("D =", D)

// 4.4
func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var found: [CrewMember] = []
    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        found.append(member)
    }
    let sortedMembers = found.sorted { $0.priority < $1.priority }
    var result: [String] = []
    for member in sortedMembers {
        result.append(member.name)
    }
    return result
}

print(evacuationOrder("Dana", "Ghost", "Aigerim", "Timur", roster: roster))
print(evacuationOrder("Nurlan", "Timur", roster: roster))


// MARK: Level 5 · The Saboteur's Logbook
/*
 Original code (kept for reference):

 func reportOxygen(for member: CrewMember) -> String {
     let tank = member.module!.oxygenTank!
     return "\(member.name): \(tank.level)%"
 }

 func firstCritical(in crew: [CrewMember]) -> String {
     var result: String?
     for member in crew {
         if oxygenLevel(of: member)! < 20 {
             result = member.name
         }
     }
     return result!
 }

 PROBLEMS:
 1. reportOxygen: `member.module!` — Nurlan has no module (open space) -> crash
    "Unexpectedly found nil while unwrapping an Optional value".
 2. reportOxygen: `oxygenTank!` — Dana is in Dock, Dock has no tank -> crash.
 3. firstCritical: `oxygenLevel(of: member)!` — crashes on Dana (Dock, no tank),
    and on Nurlan (no module).
 4. firstCritical LOGIC BUG: the loop never stops, `result` is overwritten every time,
    so it returns the LAST critical member, not the FIRST. With starter data only
    Aigerim is critical, so the bug is invisible.
 5. firstCritical: `return result!` — if nobody is critical, result is nil -> crash.
    The return type String can't express "nobody", so it must be String?.
*/

func reportOxygen(for member: CrewMember) -> String {
    guard let tank = member.module?.oxygenTank else {
        return "\(member.name): no data"
    }
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        if let level = oxygenLevel(of: member), level < 20 {
            return member.name        // stop at the FIRST one
        }
    }
    return nil                        // nobody critical
}

for member in crew {
    print(reportOxygen(for: member))
}
// Note: after the transfer Lab = 10%, Hab = 42%, so now Timur is the critical one
print("First critical:", firstCritical(in: crew) ?? "none")

// Test that proves the logic bug is fixed: TWO critical members.
let testA = CrewMember(name: "TestFirst", role: "Test", priority: 1,
                       module: Module(name: "T1", oxygenTank: Tank(level: 5)))
let testB = CrewMember(name: "TestSecond", role: "Test", priority: 2,
                       module: Module(name: "T2", oxygenTank: Tank(level: 3)))
let testCrew = [testA, testB]
print("Test (expect TestFirst):", firstCritical(in: testCrew) ?? "none",
      firstCritical(in: testCrew) == "TestFirst" ? "✅" : "❌")
let healthy = CrewMember(name: "Healthy", role: "Test", priority: 3,
                         module: Module(name: "T3", oxygenTank: Tank(level: 80)))
print("Test nobody critical (expect none):", firstCritical(in: [healthy]) ?? "none")


// MARK: Finale · Launch Code

let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("LAUNCH CODE: \(launchCode)")


// MARK: Bonus

func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var count = 0                  // captured by the closure below
    return { level in
        if level < threshold {
            count += 1
            print("Alarm #\(count)")
            return true
        }
        return false
    }
}

let alarm = makeAlarm(threshold: 20)
print(alarm(12))   // Alarm #1 -> true
print(alarm(40))   // false
print(alarm(5))    // Alarm #2 -> true


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. guard let vs if let beyond syntax:
    if let: the unwrapped value exists ONLY inside the { }.
    guard let: the value lives in the rest of the function, and the else
    MUST leave the scope (return / continue / break). So guard = "early exit",
    the happy path stays flat. With if let, parseReading would become
    4 nested ifs ("pyramid of doom"):
        if let pair = splitOnce(...) { if pair.0.isEmpty == false { if let v = Int(pair.1) { ... } } }

 2. Why can't you pass [Int] to stats(_ values: Int...)?
    Int... is a special parameter: the caller writes separate values stats(1, 2, 3)
    and Swift packs them into an array. Inside it IS [Int], but from outside the type
    is "list of Ints", not "one [Int]". Swift has no "spread" operator, so we call
    stats(of: someArray) instead.

 3. Why doesn't transferOxygen(from: &x, to: &x, amount: 5) compile?
    Exclusive access rule (overlapping access): two inout parameters can't point
    to the same variable at the same time. Otherwise source -= 5 and target += 5
    would write to the same memory and the result would be unpredictable
    (oxygen created or lost from nothing).

 4. Why doesn't oxygenLevel(of: dana) ?? "no data" compile?
    ?? needs the same type on both sides: left is Int?, so the right must be Int.
    "no data" is a String -> type mismatch. Fix: oxygenLevel(of: dana).map(String.init) ?? "no data"
    or  "\(oxygenLevel(of: dana) ?? 0)"  or use if let.

 5. Full type of chooseProtocol:
    (Int) -> (Int) -> Int
    Read it as: "a function that takes Int (the temperature) and returns
    a function (Int) -> Int". The arrow is right-associative:
    (Int) -> ((Int) -> Int).

 Bonus. Where does the alarm counter live after makeAlarm returns?
    `count` is captured by the closure. Swift moves it from the stack into a
    heap box that the closure keeps a reference to. The box lives as long as
    the closure (`alarm`) lives, so the counter survives between calls.
*/
