import Foundation

struct Turn: Codable, Equatable, Hashable, Sendable {
    let reel: Int
    let direction: Int
    var label: String { "Reel \(reel + 1) \(direction == 1 ? "up" : "down")" }
}

struct Puzzle: Identifiable, Equatable, Sendable {
    let id: String
    let number: Int
    let room: Int
    let start: [Int]
    let target: [Int]
    let limit: Int
    var isDaily: Bool { id.hasPrefix("daily-") }
    var title: String { isDaily ? "Daily puzzle" : "Level \(number)" }
    var optimal: [Turn] { Engine.solve(start, target: target, room: room)! }
    var rule: String {
        switch room {
        case 0: "Each reel turns independently."
        case 1: "Reels 1 and 2 also turn the reel to their right. Reel 3 turns alone."
        default: "Each reel also turns its neighbour: 1 → 2, 2 → 3, 3 → 1."
        }
    }
    static let rooms = ["Cherry Club", "Electric Night", "Diamond Room"]
    static let subtitles = ["Find your rhythm", "Make the connection", "Master the loop"]
    static let symbols = ["Cherry", "Star", "Bell", "Lightning", "Diamond"]
    static let levels: [Puzzle] = (1...120).map { n in
        let room = (n - 1) / 40
        let k = (n - 1) % 40
        let start = [k % 5, (k / 5 + room) % 5, (k / 25 + room * 2) % 5]
        // Forty distinct offsets per room. Fixed inputs, no randomness.
        let code = (k * 3 + 1) % 124 + 1
        let delta = [code % 5, (code / 5) % 5, code / 25]
        let target = zip(start, delta).map { ($0 + $1) % 5 }
        let optimum = Engine.solve(start, target: target, room: room)!.count
        return Puzzle(id: "level-\(n)", number: n, room: room, start: start, target: target, limit: optimum + 3)
    }
    static func dayKey(_ date: Date = Date()) -> String {
        let f = DateFormatter(); f.locale = Locale(identifier: "en_GB")
        f.timeZone = TimeZone(secondsFromGMT: 0); f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
    static func daily(_ key: String = dayKey()) -> Puzzle {
        let hash = key.utf8.reduce(UInt64(5381)) { ($0 &* 33) &+ UInt64($1) }
        let source = levels[Int(hash % 120)]
        return Puzzle(id: "daily-" + key, number: source.number, room: source.room, start: source.start, target: source.target, limit: source.limit)
    }
}

enum Engine {
    static let turns = (0..<3).flatMap { [Turn(reel: $0, direction: 1), Turn(reel: $0, direction: -1)] }
    static func affected(_ reel: Int, room: Int) -> [Int] {
        if room == 0 || (room == 1 && reel == 2) { return [reel] }
        return [reel, (reel + 1) % 3]
    }
    static func apply(_ turn: Turn, to state: [Int], room: Int) -> [Int] {
        var result = state
        for i in affected(turn.reel, room: room) { result[i] = (result[i] + turn.direction + 5) % 5 }
        return result
    }
    // Breadth-first search across all 125 possible states gives a true shortest path.
    static func solve(_ start: [Int], target: [Int], room: Int) -> [Turn]? {
        if start == target { return [] }
        var queue: [([Int], [Turn])] = [(start, [])]
        var seen: Set<[Int]> = [start]
        var cursor = 0
        while cursor < queue.count {
            let (state, path) = queue[cursor]; cursor += 1
            for turn in turns {
                let next = apply(turn, to: state, room: room)
                guard seen.insert(next).inserted else { continue }
                if next == target { return path + [turn] }
                queue.append((next, path + [turn]))
            }
        }
        return nil
    }
    static func stars(moves: Int, optimum: Int) -> Int { moves <= optimum ? 3 : moves == optimum + 1 ? 2 : 1 }
}

struct Attempt: Codable, Equatable {
    var state: [Int]
    var history: [[Int]] = []
    var moves: Int { history.count }
    mutating func turn(_ turn: Turn, puzzle: Puzzle) {
        guard moves < puzzle.limit else { return }
        history.append(state); state = Engine.apply(turn, to: state, room: puzzle.room)
    }
    mutating func undo() { if let previous = history.popLast() { state = previous } }
}
struct Record: Codable, Equatable {
    var moves: Int
    var stars: Int
}
struct ProgressData: Codable, Equatable {
    var version = 1
    var records: [String: Record] = [:]
    var attempts: [String: Attempt] = [:]
    var lastLevel = 1
    var haptics = true
    var reducedMotion = false
    var completed: Int { records.keys.filter { $0.hasPrefix("level-") }.count }
    mutating func record(_ puzzle: Puzzle, moves: Int) {
        guard records[puzzle.id].map({ moves < $0.moves }) ?? true else { return }
        records[puzzle.id] = Record(moves: moves, stars: Engine.stars(moves: moves, optimum: puzzle.optimal.count))
    }
    func validated() throws -> ProgressData {
        guard version == 1, (1...120).contains(lastLevel), attempts.values.allSatisfy({ a in
            a.state.count == 3 && a.state.allSatisfy { (0..<5).contains($0) } && a.history.count <= 20 && a.history.allSatisfy { $0.count == 3 && $0.allSatisfy { (0..<5).contains($0) } }
        }), records.values.allSatisfy({ $0.moves >= 0 && (1...3).contains($0.stars) }) else { throw CocoaError(.coderReadCorrupt) }
        return self
    }
}
