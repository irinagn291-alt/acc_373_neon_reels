import SwiftUI

@MainActor final class GameStore: ObservableObject {
    @Published var data = ProgressData()
    @Published var loaded = false
    @Published var error: String?
    private var readFailed = false
    #if DEBUG && targetEnvironment(simulator)
    private var screenshotStore = false
    func prepareScreenshot(_ key: String) {
        screenshotStore = true
        data = ProgressData()
        data.haptics = false
        data.reducedMotion = true
        func complete(_ puzzle: Puzzle) {
            var attempt = Attempt(state: puzzle.start)
            for turn in puzzle.optimal { attempt.turn(turn, puzzle: puzzle) }
            update(attempt, for: puzzle)
            self.complete(puzzle, attempt: attempt)
        }
        switch key {
        case "puzzle-hall", "symbol-detail": complete(Puzzle.levels[0])
        case "symbol-album":
            for puzzle in Puzzle.levels.prefix(5) { complete(puzzle) }
        case "daily-puzzle": complete(Puzzle.daily())
        case "linked-reel-puzzle":
            let puzzle = Puzzle.levels[40]
            var attempt = Attempt(state: puzzle.start)
            attempt.turn(Turn(reel: 0, direction: 1), puzzle: puzzle)
            update(attempt, for: puzzle)
        case "puzzle-result": complete(Puzzle.levels[0])
        default: break
        }
        loaded = true
    }
    #endif
    let url: URL
    init(url: URL? = nil) {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        self.url = url ?? root.appendingPathComponent("NeonReels/progress-v1.json")
    }
    func load() {
        #if DEBUG && targetEnvironment(simulator)
        if screenshotStore { loaded = true; return }
        #endif
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                data = try JSONDecoder().decode(ProgressData.self, from: Data(contentsOf: url)).validated()
            }
            readFailed = false; error = nil
        } catch {
            readFailed = true
            self.error = "Your saved progress could not be read. Retry in Settings, or reset the local save. The original file has not been overwritten."
        }
        loaded = true
        if !readFailed { publishWidget() }
    }
    func save() {
        #if DEBUG && targetEnvironment(simulator)
        if screenshotStore { return }
        #endif
        guard !readFailed else { return }
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try JSONEncoder().encode(data).write(to: url, options: .atomic)
            error = nil; publishWidget()
        } catch { self.error = "Progress could not be saved on this device. Your current session is still available. Free some storage and tap Retry save in Settings." }
    }
    func retry() { if readFailed { load() } else { save() } }
    func reset() {
        #if DEBUG && targetEnvironment(simulator)
        if screenshotStore { data = ProgressData(); return }
        #endif
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                let backup = url.deletingLastPathComponent().appendingPathComponent("progress-backup-\(UUID().uuidString).json")
                try FileManager.default.copyItem(at: url, to: backup)
            }
            data = ProgressData(); readFailed = false; save()
        } catch { self.error = "Could not back up the previous save. Reset was cancelled. Please free some storage and try again." }
    }
    func attempt(_ p: Puzzle) -> Attempt { data.attempts[p.id] ?? Attempt(state: p.start) }
    func update(_ attempt: Attempt, for p: Puzzle) {
        data.attempts[p.id] = attempt
        if !p.isDaily { data.lastLevel = p.number }
        save()
    }
    func complete(_ p: Puzzle, attempt: Attempt) {
        data.record(p, moves: attempt.moves)
        if !p.isDaily && p.number < 120 { data.lastLevel = p.number + 1 }
        save()
    }
    func roomCount(_ room: Int) -> Int { Puzzle.levels.filter { $0.room == room && data.records[$0.id] != nil }.count }
    func unlocked(_ symbol: Int) -> Bool { data.completed >= [0, 1, 5, 15, 30][symbol] }
}
