// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · The Deck Register

// 1.1  Raw values are assigned by Swift: "bridge", "lab", ...
enum Deck: String, CaseIterable {
    case bridge, lab, cargo, medbay, engine

    var evacuationPriority: Int {
        switch self {          // no default: the compiler checks every case
        case .bridge: return 1
        case .medbay: return 2
        case .lab:    return 3
        case .engine: return 4
        case .cargo:  return 5
        }
    }
}

for deck in Deck.allCases {
    print("Deck \(deck.rawValue): priority \(deck.evacuationPriority)")
}

// 1.2  Only green = 0 written; yellow = 1, orange = 2, red = 3 implicitly
enum AlarmLevel: Int {
    case green = 0
    case yellow, orange, red

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let step = min(max(mass, 0) / 500, AlarmLevel.red.rawValue)   // every full 500 kg = +1, capped at red
        return AlarmLevel(rawValue: step) ?? .red
    }
}

print(AlarmLevel.level(forTotalMass: 0))      // green
print(AlarmLevel.level(forTotalMass: 940))    // yellow
print(AlarmLevel.level(forTotalMass: 4000))   // red
print(AlarmLevel.orange.rawValue)             // 2


// MARK: Level 2 · The Manifest

// 2.1
enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}

// 2.2  Never crashes, never returns an optional: .unknown is the error case
func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line)
    switch parts[0] {                                   // fields() always returns at least 1 element
    case "crate":
        guard parts.count == 3, let id = Int(parts[1]), let mass = Int(parts[2]) else {
            return .unknown(raw: line)
        }
        return .crate(id: id, massKg: mass)
    case "container":
        guard parts.count == 3, let mass = Int(parts[2]) else {
            return .unknown(raw: line)
        }
        return .container(code: parts[1], massKg: mass)
    case "livestock":
        guard parts.count == 4, let count = Int(parts[2]), let perUnit = Int(parts[3]) else {
            return .unknown(raw: line)
        }
        return .livestock(species: parts[1], count: count, massPerUnitKg: perUnit)
    default:
        return .unknown(raw: line)
    }
}

print(parseEntry("crate:101:120"))
print(parseEntry("livestock:lab mice:12:2"))
print(parseEntry("crate:104:abc"))

// 2.3
func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case .crate(_, let massKg):
        return massKg
    case .container(_, let massKg):
        return massKg
    case .livestock(_, let count, let massPerUnitKg):
        return count * massPerUnitKg
    case .unknown:
        return 0
    }
}

var totalMass = 0
var unknownCount = 0
for line in rawManifest {
    let entry = parseEntry(line)
    totalMass += mass(of: entry)
    if case .unknown = entry {
        unknownCount += 1
    }
}
print("Total manifest mass: \(totalMass) kg, unknown lines: \(unknownCount)")
print("Mass of one container:", mass(of: parseEntry("container:KZ-ALM-7:340")))

let A = totalMass


// MARK: Level 3 · Crew Snapshots

// 3.1  No init written: a struct gets a free memberwise init
struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(_ amount: Int) {
        oxygen = max(0, oxygen - amount)        // never below 0
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)   // whole new value
    }

    static func rookie(named name: String) -> CrewSnapshot {
        CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

var rookie = CrewSnapshot.rookie(named: "Aliya")
print(rookie)
rookie.breathe(130)
print("After breathe(130):", rookie.oxygen)   // 0, not negative
rookie.move(to: .engine)
rookie.reviveInMedbay()
print("After revive:", rookie)

// 3.2
var builtRoster: [CrewSnapshot] = []
for record in crewData {
    guard let deck = Deck(rawValue: record.deck) else {
        print("⚠️ Warning: unknown deck '\(record.deck)' for \(record.name), skipped")
        continue
    }
    builtRoster.append(CrewSnapshot(name: record.name, deck: deck, oxygen: record.oxygen))
}
let crewRoster: [CrewSnapshot] = builtRoster
print("Crew roster:", crewRoster.count, "members")
print(crewRoster[0])

// 3.3 · Value-semantics demonstration
// (1) copy
let original = CrewSnapshot.rookie(named: "Copy-Test")
var copy = original
print("1) before: original \(original.oxygen), copy \(copy.oxygen)")
copy.breathe(50)
print("1) after:  original \(original.oxygen), copy \(copy.oxygen)")   // original still 100

// (2) plain parameter: the function gets its own copy
func drainPlain(_ snapshot: CrewSnapshot) -> Int {
    var local = snapshot          // parameters are constants, so we copy into a var
    local.breathe(70)
    return local.oxygen
}
let plainTest = CrewSnapshot.rookie(named: "Plain-Test")
print("2) before: \(plainTest.oxygen)")
let insideValue = drainPlain(plainTest)
print("2) after:  original \(plainTest.oxygen), inside function was \(insideValue)")

// (3) inout: the function writes back into the original
func drainInout(_ snapshot: inout CrewSnapshot) {
    snapshot.breathe(70)
}
var inoutTest = CrewSnapshot.rookie(named: "Inout-Test")
print("3) before: \(inoutTest.oxygen)")
drainInout(&inoutTest)
print("3) after:  \(inoutTest.oxygen)")   // 30 — changed


// MARK: Level 4 · The Teleport Pod

// 4.1
// Class, because the pod is ONE physical device: everyone who holds it must see the same charge.
// Why no free init: classes never get a memberwise init (only structs do), and a class
// must have all stored properties set before use, so we write init ourselves.
final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    func load(_ crew: CrewSnapshot) -> Bool {
        guard occupant == nil, chargeLevel >= 20 else { return false }
        occupant = crew
        return true
    }

    func fire() -> CrewSnapshot? {
        guard let passenger = occupant else { return nil }   // empty pod: nil, no charge spent
        chargeLevel -= 20
        occupant = nil
        return passenger
    }

    // Bonus 1
    deinit {
        print("🗑 deinit TeleportPod \(id)")
    }
}

// 4.2 · Charge ledger
func findCrew(_ name: String) -> CrewSnapshot? {
    for member in crewRoster where member.name == name {
        return member
    }
    return nil
}

let pod1 = TeleportPod(id: "P-1", chargeLevel: 100)
for name in ["Timur", "Dana", "Nurlan"] {
    if let member = findCrew(name) {
        let loaded = pod1.load(member)
        let arrived = pod1.fire()
        print("load \(name): \(loaded), fired: \(arrived?.name ?? "nobody"), charge \(pod1.chargeLevel)")
    }
}
let emptyFire = pod1.fire()
print("fire empty pod: \(emptyFire?.name ?? "nobody"), charge \(pod1.chargeLevel)")

let C = pod1.chargeLevel

// Extra test: load fails when the pod is occupied
let busyPod = TeleportPod(id: "P-2", chargeLevel: 100)
print("first load:", busyPod.load(CrewSnapshot.rookie(named: "X")))    // true
print("second load:", busyPod.load(CrewSnapshot.rookie(named: "Y")))   // false, occupied

// 4.3 · Reference-semantics demonstration
let podRef1 = TeleportPod(id: "REF", chargeLevel: 100)
let podRef2 = podRef1                     // same object, two names
podRef2.chargeLevel = 33
print("class:  podRef1 \(podRef1.chargeLevel), podRef2 \(podRef2.chargeLevel)")   // both 33

let snapA = CrewSnapshot.rookie(named: "Value")
var snapB = snapA                         // independent copy
snapB.oxygen = 33
print("struct: snapA \(snapA.oxygen), snapB \(snapB.oxygen)")       // 100 and 33
// Rule: assigning a class copies the REFERENCE (one shared object); assigning a struct copies the VALUE.


// MARK: Level 5 · Station Systems

// 5.1  Class: the station's live state is one shared object.
final class Station {
    // stored let
    let callSign: String

    // stored var with observers
    var hullIntegrity: Int {
        willSet {
            print("Hull: \(hullIntegrity) -> \(newValue)")
        }
        didSet {
            if hullIntegrity > 100 {
                hullIntegrity = 100
            } else if hullIntegrity < 0 {
                hullIntegrity = 0
            }
        }
    }

    var oxygenByDeck: [Deck: Int]

    // lazy stored: built only on first access
    lazy var fullDiagnostics: String = {
        print("Running full scan...")
        var report = "\(callSign) diagnostics:"
        for deck in Deck.allCases {
            report += " \(deck.rawValue)=\(oxygenByDeck[deck] ?? 0)"
        }
        return report
    }()

    // computed read-only, no `get` keyword
    var totalOxygen: Int {
        var sum = 0
        for (_, value) in oxygenByDeck {
            sum += value
        }
        return sum
    }

    // computed get + set, default `newValue`
    var averageOxygen: Int {
        get {
            guard oxygenByDeck.count > 0 else { return 0 }
            return totalOxygen / oxygenByDeck.count
        }
        set {
            for deck in Deck.allCases where oxygenByDeck[deck] != nil {
                oxygenByDeck[deck] = newValue
            }
        }
    }

    init(callSign: String, readings: [(deck: String, oxygen: Int)]) {
        self.callSign = callSign
        self.hullIntegrity = 100
        var map: [Deck: Int] = [:]
        for reading in readings {
            guard let deck = Deck(rawValue: reading.deck) else {
                print("⚠️ Skipping reading for unknown deck '\(reading.deck)'")
                continue
            }
            map[deck] = reading.oxygen
        }
        self.oxygenByDeck = map
    }
}

let station = Station(callSign: "ALMA-7", readings: deckReadings)
print("Call sign:", station.callSign)
print("Total oxygen:", station.totalOxygen)
let B = station.averageOxygen          // at start-up, before any change
print("Average oxygen at start:", B)

// lazy proof
print("-- before first access to fullDiagnostics")
print(station.fullDiagnostics)         // "Running full scan..." printed here
print("-- second access:")
print(station.fullDiagnostics)         // no scan message this time
let untouched = Station(callSign: "SPARE", readings: [])
print("Spare station created, diagnostics never touched -> no scan message:", untouched.callSign)

// setter test
station.averageOxygen = 70
print("After averageOxygen = 70:", station.oxygenByDeck[.cargo] ?? 0, station.totalOxygen)

// 5.2 · The clamp trap
station.hullIntegrity = 130
print("hull =", station.hullIntegrity)   // 100
station.hullIntegrity = -40
print("hull =", station.hullIntegrity)   // 0
station.hullIntegrity = 55
print("hull =", station.hullIntegrity)   // 55
// Why no infinite loop: assigning a property inside its OWN didSet does not
// call willSet/didSet again — Swift writes the storage directly.


// MARK: Level 6 · Incident Reports
/*
 // Report 1
 var roster = crewRoster
 for var member in roster {
     member.oxygen -= 10
 }
 print(roster[0].oxygen)
 Expected: everyone loses 10 oxygen.
 Actual: compiles, prints 62 — nothing changed.
 Rule: `for var member` gives a COPY of each struct element; changing the copy
 doesn't touch the array (value semantics).
 Fix:
     for i in roster.indices { roster[i].oxygen -= 10 }

 // Report 2
 let podA = TeleportPod(id: "A", chargeLevel: 100)
 let podB = podA
 podB.chargeLevel = 0
 print(podA.chargeLevel)
 Expected: 100. Actual: compiles, prints 0.
 Rule: classes are reference types; `podB = podA` copies the reference,
 both names point to ONE pod.
 Fix: create a second pod: let podB = TeleportPod(id: "B", chargeLevel: podA.chargeLevel)

 // Report 3
 struct Logbook {
     var entries: [String] = []
     func add(_ entry: String) { entries.append(entry) }
 }
 Does NOT compile:
 error: cannot use mutating member on immutable value: 'self' is immutable
 Rule: methods of a struct can't change its properties unless marked `mutating`
 (self is a constant inside normal struct methods).
 Fix: mutating func add(_ entry: String) { entries.append(entry) }

 // Report 4
 let snapshot = CrewSnapshot.rookie(named: "Dana")
 snapshot.oxygen = 40          // ❌ error: cannot assign to property: 'snapshot' is a 'let' constant
 let pod = TeleportPod(id: "B", chargeLevel: 50)
 pod.chargeLevel = 10          // ✅ compiles
 Rule: for a STRUCT, `let` freezes the whole value, including every var property.
 For a CLASS, `let` freezes only the reference (you can't point `pod` at another pod),
 but the object it points to can still be changed through its var properties.
 Fix: var snapshot = CrewSnapshot.rookie(named: "Dana")
*/


// MARK: Level 7 · Sealing the Black Box

final class FlightRecorder {
    // private: blocks any reading/replacing/clearing of the list from outside the type
    private var entries: [String] = []

    // private(set): blocks writing from outside (can't set back to false), reading is allowed
    private(set) var isSealed = false

    // internal: allows outside code to read the count, but there is no setter
    internal var entryCount: Int {
        entries.count
    }

    // internal: allows reading a formatted transcript, nothing can be changed through it
    internal var transcript: String {
        var text = ""
        for (index, entry) in entries.enumerated() {
            text += "\(index + 1). \(entry)\n"
        }
        return text
    }

    // internal: the only way to add; blocks adding after sealing by returning false
    @discardableResult
    internal func add(_ entry: String) -> Bool {
        guard isSealed == false else { return false }
        entries.append(entry)
        return true
    }

    // internal: allows sealing; there is no method to unseal
    internal func seal() {
        isSealed = true
    }

    // fileprivate: blocks use from other files, but lets the free audit function in THIS file read raw entries
    fileprivate func rawEntries() -> [String] {
        entries
    }
}

// Free function elsewhere in the file using the fileprivate helper
func auditTranscript(of recorder: FlightRecorder) -> String {
    let raw = recorder.rawEntries()
    return "AUDIT: \(raw.count) entries, sealed = \(recorder.isSealed), last = \(raw.last ?? "none")"
}

let recorder = FlightRecorder()
recorder.add("03:14 meteorite impact")
recorder.add("09:00 teleporter online")
print(recorder.transcript, terminator: "")
recorder.seal()
print("Add after seal:", recorder.add("forged entry"))   // false
print("Entries:", recorder.entryCount, "sealed:", recorder.isSealed)
print(auditTranscript(of: recorder))

// Trying to break it from outside:
// recorder.entries = []
// error: 'entries' is inaccessible due to 'private' protection level
// recorder.isSealed = false
// error: cannot assign to property: 'isSealed' setter is inaccessible


// MARK: Finale · Integrity Code

let D = AlarmLevel.level(forTotalMass: A).rawValue
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("INTEGRITY CODE: \(integrityCode)")


// MARK: Bonus

// 2. Lifetime experiment
print("-- before do block")
do {
    let tempPod = TeleportPod(id: "TEMP", chargeLevel: 10)
    let secondRef = tempPod
    print("inside do: \(tempPod.id) and \(secondRef.id) are the same pod")
    print("-- end of do block")
}   // <- deinit fires here: the last strong reference (secondRef) goes out of scope
print("-- after do block")

// 3. Identity vs equal contents
func comparePods(_ a: TeleportPod, _ b: TeleportPod) -> String {
    if a === b {
        return "same pod (one object)"
    }
    if a.id == b.id && a.chargeLevel == b.chargeLevel {
        return "two different pods with equal contents"
    }
    return "two different pods"
}
let record1 = TeleportPod(id: "Q", chargeLevel: 50)
let record2 = record1
let record3 = TeleportPod(id: "Q", chargeLevel: 50)
print(comparePods(record1, record2))   // same pod
print(comparePods(record1, record3))   // equal contents
// === can't be used on CrewSnapshot: it's a struct (value type), it has no identity —
// every copy is a separate value, there is no shared object to compare addresses of.


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Structs get an automatic memberwise init (CrewSnapshot(name:deck:oxygen:)).
    Classes never get one — because of inheritance Swift can't know how to init
    parent/child properties, so if a class has stored properties without default
    values, we must write init ourselves.

 2. `mutating` lets a method change self: Swift passes self as inout, and the
    method can change properties or even replace self entirely (self = ...).
    Classes don't need it: self is a reference, the method changes the object
    it points to, not the reference itself.

 3. Struct + let: the whole value is frozen, no property can change.
    Class + let: only the reference is frozen (can't point to another object);
    the object's var properties can still change.

 4. lazy must be var because its value is set AFTER init (on first access) — a let
    must be set during init. Behaviour change: fullDiagnostics prints
    "Running full scan..." and reads oxygenByDeck at the moment of first access;
    if never accessed, nothing is printed and the scan never happens. If oxygen
    changes before the first access, the report shows the NEW values.

 5. entries is private, so the free function auditTranscript (outside the class)
    couldn't read it. Making entries public would let anyone clear it.
    fileprivate rawEntries() is the middle ground: visible to the audit function
    in this file, invisible to other files.

 Bonus. deinit fires at the closing brace of the do block, when the last strong
 reference disappears (ARC count drops to 0). Swift may release even a bit
 earlier, after the last use. === needs a class instance (reference); a struct
 has no identity, so === doesn't compile for CrewSnapshot.
*/
