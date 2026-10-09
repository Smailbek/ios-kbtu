// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section. LegacyBeacon in
//     particular must be reached with an extension, not edited.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • The Health Rule must exist in exactly ONE place in this file.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 5.3 · Extending a type you didn't write
// (placed first so every type below can use it)
extension Int {
    /// 42 -> "####......"  (10 chars, clamped so -5 and 250 don't break it)
    var powerBar: String {
        let filled = (self / 10).clamped(to: 0...10)
        var bar = ""
        for position in 0..<10 {
            bar += position < filled ? "#" : "."
        }
        return bar
    }

    /// Keeps a value inside a range: 130.clamped(to: 0...100) == 100
    func clamped(to range: ClosedRange<Int>) -> Int {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }

    /// The single home of the recharge rule (used by PowerCell AND SensorModule):
    /// non-positive amounts are ignored, never above 100.
    func recharged(by amount: Int) -> Int {
        guard amount > 0 else { return self }
        return (self + amount).clamped(to: 0...100)
    }
}

print(42.powerBar, (-5).powerBar, 250.powerBar)   // ####...... .......... ##########
print(130.clamped(to: 0...100), 95.recharged(by: 30), 50.recharged(by: -10))


// MARK: Level 1 · The Power Cell

// Why a class and not a struct here?  -> The cell is one physical battery shared by
// reference: the drone holds it as `let cell`, and spend/recharge must change THAT battery,
// which a struct (value copied, frozen by `let`) could not do.
final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        self.charge = charge.clamped(to: 0...100)
    }

    func level() -> Int {
        charge
    }

    func spend(_ amount: Int) -> Bool {
        guard amount > 0, amount <= charge else { return false }   // nothing changes on failure
        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        charge = charge.recharged(by: amount)
    }
}

let cell = PowerCell(charge: 150)
print("Cell clamped:", cell.level())                  // 100
print("spend(30):", cell.spend(30), cell.level())     // true 70
print("spend(0):", cell.spend(0), cell.level())       // false 70
print("spend(500):", cell.spend(500), cell.level())   // false 70
cell.recharge(by: 50)
print("recharge(50):", cell.level())                  // 100, never above
print("PowerCell(charge: -20):", PowerCell(charge: -20).level())   // 0

// Encapsulation proof (leave this commented, with the compiler error):
// cell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level


// MARK: Level 4.1 · Diagnosable  (declared before Drone so Drone can conform)

protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

// MARK: Level 4.2 · Rechargeable

protocol Rechargeable {
    mutating func recharge(by amount: Int)
}


// MARK: Level 5.1 · default diagnose() + the single home of the Health Rule

extension Diagnosable {
    func diagnose() -> String {
        "\(componentID): code \(statusCode)"
    }

    /// THE HEALTH RULE — the only place in the file with these thresholds.
    /// below 20 -> 2 (critical), 20...49 -> 1 (warning), 50+ -> 0 (nominal)
    func healthCode(for level: Int) -> Int {
        if level < 20 { return 2 }
        if level < 50 { return 1 }
        return 0
    }
}


// MARK: Level 2 · The Fleet

// 2.1  What does `final` on runOnce() buy you?  -> No subclass can override the shift
// ritual, so "spend first, work only if the spend succeeded" is guaranteed for every drone.
class Drone: Diagnosable, Rechargeable {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { 10 }                       // overridable

    var statusLine: String {                        // "W-1: 80% [########..]"
        "\(id): \(cell.level())% [\(cell.level().powerBar)]"
    }

    func performTask() -> Int { 0 }                 // a bare drone does nothing

    final func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }   // not enough charge -> no work, no crash
        return performTask()
    }

    /// enough charge for one more task?
    var canRunTask: Bool {
        cell.level() >= powerCost
    }

    // Diagnosable
    var componentID: String { id }
    var statusCode: Int { healthCode(for: cell.level()) }

    // Rechargeable
    // Why does Drone implement recharge(by:) without `mutating`?  -> Drone is a class
    // (reference type): the method changes the object `self` points to, never `self` itself,
    // so there is nothing for `mutating` to allow.
    func recharge(by amount: Int) {
        cell.recharge(by: amount)
    }
}

// 2.2
final class WelderDrone: Drone {
    override var powerCost: Int { 25 }
    override func performTask() -> Int { 40 }

    func weldSeam() -> String {
        "\(id) welded a hull seam 🔥"
    }
}

class ScannerDrone: Drone {
    override var powerCost: Int { 10 }
    override func performTask() -> Int { 15 }

    override var statusLine: String {
        super.statusLine + " [scanner]"            // reuse, don't rebuild
    }
}

final class CargoDrone: Drone {
    override var powerCost: Int { 20 }
    override func performTask() -> Int { 25 }
}

// 2.3
func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder":  return WelderDrone(id: id, cell: cell)
    case "scanner": return ScannerDrone(id: id, cell: cell)
    case "cargo":   return CargoDrone(id: id, cell: cell)
    default:        return nil
    }
}

var builtFleet: [Drone] = []
for record in fleetData {
    guard let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) else {
        print("⚠️ Unknown drone kind '\(record.kind)' for \(record.id) — skipped")
        continue
    }
    builtFleet.append(drone)
}
let fleet: [Drone] = builtFleet
print("Fleet built: \(fleet.count) drones")

for drone in fleet {
    print(drone.statusLine)
}


// MARK: Level 3 · The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    var total = 0
    for _ in 0..<max(rounds, 0) {
        for drone in fleet {
            total += drone.runOnce()      // one call, different behaviour per object
        }
    }
    return total
}

let A = runShift(fleet, rounds: 3)
print("Shift finished. Work units:", A)

var chargeSum = 0
var readyCount = 0
for drone in fleet {
    print(drone.statusLine)
    chargeSum += drone.cell.level()
    if drone.canRunTask {
        readyCount += 1
    }
}
print("Drones ready for one more task:", readyCount)

let B = chargeSum
let C = readyCount

// A second shift on a separate test fleet (does not touch the mission fleet)
let testFleet: [Drone] = [CargoDrone(id: "TEST", cell: PowerCell(charge: 30))]
print("Test shift (30% cargo, 3 rounds):", runShift(testFleet, rounds: 3), "->", testFleet[0].statusLine)


// MARK: Level 4 · Diagnostics

// 4.2 · SensorModule — a struct, so recharge must be `mutating`
struct SensorModule: Diagnosable, Rechargeable {
    let id: String
    var chargeLevel: Int

    var componentID: String { id }
    var statusCode: Int { healthCode(for: chargeLevel) }

    mutating func recharge(by amount: Int) {
        chargeLevel = chargeLevel.recharged(by: amount)
    }
}

var sensors: [SensorModule] = []
for record in sensorData {
    sensors.append(SensorModule(id: record.id, chargeLevel: record.charge))
}

// Rechargeable demo on COPIES, so the mission data stays untouched
var testSensor = sensors[0]
testSensor.recharge(by: 50)
print("Sensor copy recharged: \(testSensor.chargeLevel), original still \(sensors[0].chargeLevel)")
let spareDrone = ScannerDrone(id: "S-TEST", cell: PowerCell(charge: 10))
spareDrone.recharge(by: 30)
print("Spare drone recharged:", spareDrone.statusLine)

// 4.3
// Why could [Drone] never have held the sensors?  -> SensorModule is a struct, and a struct
// can't inherit from the Drone class, so it is not a Drone; it only shares the Diagnosable protocol.
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var report = "=== DIAGNOSTICS (\(components.count) components) ===\n"
    for component in components {
        report += component.diagnose() + "\n"
    }
    return report
}

var components: [Diagnosable] = []
for drone in fleet { components.append(drone) }
for sensor in sensors { components.append(sensor) }
print(diagnosticsReport(components))


// MARK: Level 5 · Shared Behaviour

// 5.2 · the beacon you cannot edit
extension LegacyBeacon: Diagnosable {
    var componentID: String { name }
    var statusCode: Int { healthCode(for: signalStrength) }

    func diagnose() -> String {
        "📡 LEGACY HARDWARE \(name) | signal \(signalStrength) | code \(statusCode) | manual check required"
    }
}

components.append(beacon)
print(diagnosticsReport(components))

var statusSum = 0
for component in components {
    statusSum += component.statusCode
}
let D = statusSum
print("Sum of status codes:", D)


// MARK: Level 6 · Incident Reports
// For each: expectation, actual behaviour, the language rule, the fix.

/*
// Report 1
class PatchDrone: Drone {
    func performTask() -> Int {
        return 30
    }
}
 Expected: a new drone that produces 30 units.
 Actual: does NOT compile —
   error: overriding declaration requires an 'override' keyword
 Rule: if a subclass method has the same signature as a superclass method, it must
 say `override` explicitly (protects you from overriding by accident).
 Fix:  override func performTask() -> Int { 30 }

// Report 2
final class HeavyWelder: WelderDrone {
    override func runOnce() -> Int {
        return 999
    }
}
 Expected: a welder that cheats and returns 999 without spending charge.
 Actual: does NOT compile, two errors —
   error: inheritance from a final class 'WelderDrone'
   error: instance method overrides a 'final' instance method
 Rule: a `final` class can't be subclassed; a `final` method can't be overridden.
 Fix: subclass Drone (not WelderDrone) and change only powerCost / performTask:
   final class HeavyWelder: Drone {
       override var powerCost: Int { 50 }
       override func performTask() -> Int { 100 }
   }

// Report 3
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
print(first.weldSeam())
 Expected: the welder welds.
 Actual: does NOT compile —
   error: value of type 'Drone' has no member 'weldSeam'
 Rule: the compiler checks the STATIC type. `first` is a Drone, and Drone has no weldSeam(),
 even though at runtime the object really is a WelderDrone.
 Fix: conditional cast (see the working code below this comment).
 Why `as?` returns an optional: the cast can fail at runtime (the element might be a
 ScannerDrone), so the result is WelderDrone? — nil if it isn't a welder.

// Report 4
protocol Labelled {
    var componentID: String { get }
}
extension Labelled {
    func label() -> String { "generic component" }
}
struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}
let parts: [Labelled] = [Thruster(componentID: "T-1")]
print(parts[0].label())
 Expected: "thruster T-1".  Actual: compiles and prints "generic component" (it lies).
 Rule: label() is NOT a protocol requirement, it only exists in the extension.
 Methods that are only in an extension use STATIC dispatch: the compiler looks at the
 variable's type (Labelled), not at the real object, so the extension version is called.
 Requirements use DYNAMIC dispatch (witness table) and call the type's own version.
 Fix (one line): add the method to the protocol:
   protocol Labelled {
       var componentID: String { get }
       func label() -> String        // <- this line
   }
*/

// Report 3 — fixed with a conditional cast
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100)),
                            ScannerDrone(id: "S-9", cell: PowerCell(charge: 100))]
for drone in reportFleet {
    if let welder = drone as? WelderDrone {
        print(welder.weldSeam())
    } else {
        print("\(drone.id) is not a welder")
    }
}

// Report 4 — fixed version (renamed so it doesn't clash with the commented original)
protocol LabelledFixed {
    var componentID: String { get }
    func label() -> String                  // now a requirement -> dynamic dispatch
}
extension LabelledFixed {
    func label() -> String { "generic component" }
}
struct ThrusterFixed: LabelledFixed {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}
let fixedParts: [LabelledFixed] = [ThrusterFixed(componentID: "T-1")]
print(fixedParts[0].label())                // thruster T-1


// MARK: Finale · Mission Code

let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")


// MARK: Bonus

// 1a. Runtime check: crash if someone creates the base type directly.
class AbstractDroneDemo {
    init() {
        if type(of: self) == AbstractDroneDemo.self {
            fatalError("AbstractDroneDemo is abstract — create a subclass")
        }
    }
    func performTask() -> Int {
        fatalError("Subclass must override performTask()")
    }
}
final class ConcreteDemo: AbstractDroneDemo {
    override func performTask() -> Int { 1 }
}
print("Concrete subclass works:", ConcreteDemo().performTask())
// let bad = AbstractDroneDemo()   // compiles, but CRASHES at runtime

// 1b. Compile-time check: a protocol can't be instantiated, and a requirement
//     without a default implementation MUST be written by every conformer.
//     DroneUnit()  -> error: 'any DroneUnit' cannot be constructed because it has no accessible initializers

// 2. Protocol-based redesign
protocol DroneUnit: Diagnosable {
    var id: String { get }
    var cell: PowerCell { get }
    var powerCost: Int { get }
    func performTask() -> Int          // no default -> compile-time "abstract"
}

extension DroneUnit {
    var powerCost: Int { 10 }
    var componentID: String { id }
    var statusCode: Int { healthCode(for: cell.level()) }
    var statusLine: String { "\(id): \(cell.level())% [\(cell.level().powerBar)]" }

    func runOnce() -> Int {            // not a requirement -> conformers can't really replace it via DroneUnit
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}

enum V2 {   // namespace, so names don't clash with the class-based fleet
    struct WelderDrone: DroneUnit {
        let id: String
        let cell: PowerCell
        var powerCost: Int { 25 }
        func performTask() -> Int { 40 }
        func weldSeam() -> String { "\(id) welded (struct version)" }
    }
    struct ScannerDrone: DroneUnit {
        let id: String
        let cell: PowerCell
        func performTask() -> Int { 15 }
    }
    struct CargoDrone: DroneUnit {
        let id: String
        let cell: PowerCell
        var powerCost: Int { 20 }
        func performTask() -> Int { 25 }
    }
}

let fleetV2: [DroneUnit] = [
    V2.WelderDrone(id: "W-V2", cell: PowerCell(charge: 80)),
    V2.ScannerDrone(id: "S-V2", cell: PowerCell(charge: 45)),
    V2.CargoDrone(id: "C-V2", cell: PowerCell(charge: 100))
]
var workV2 = 0
for drone in fleetV2 {
    workV2 += drone.runOnce()
    print("V2", drone.statusLine)
}
print("V2 one round work:", workV2)

// 3. Comparison:
// The class design gives `final runOnce()` (a ritual nobody can change) and shared stored
// properties via inheritance; the protocol design lets structs, classes and even foreign types
// be drones, and makes "abstract" a compile-time rule. For this station I'd keep the class
// version: drones are physical machines with identity and shared mutable state (the cell);
// if drones had to share mutable state without PowerCell being a class, structs would copy it
// and every copy would drift apart, so classes would be the only correct choice.


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why does a class satisfy a `mutating` protocol requirement without the
    keyword, while a struct must write it?
    `mutating` means "this method may change self". For a struct, self IS the value,
    so changing chargeLevel changes self — Swift must know (and forbids it on `let`).
    For a class, self is a reference; the method changes the object, not the reference,
    so the requirement is satisfied without the keyword.

 2. One thing inheritance does that protocols cannot, and one thing
    protocols do that inheritance cannot:
    Inheritance: shares STORED properties and an init (id, cell) and lets me lock a
    method with `final` + call `super`.
    Protocols: work for structs, enums and types I can't edit (LegacyBeacon via
    extension), and one type can conform to many protocols (Diagnosable + Rechargeable),
    while a class has only one superclass.

 3. What does `final` prevent, and what did it protect in runOnce()?
    `final` forbids overriding (on a method/property) or subclassing (on a class).
    On runOnce() it guarantees that every drone pays powerCost BEFORE working —
    no subclass can skip the spend and produce work for free (see Report 2).

 4. In Report 4, why did the protocol extension's method win?
    label() was not declared in the protocol, only in the extension, so the call
    through a `Labelled` value is statically dispatched: the compiler picks the
    extension's version by the variable's type. Only protocol requirements are
    dynamically dispatched to the real type's implementation.
*/
