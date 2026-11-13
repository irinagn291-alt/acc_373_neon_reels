import Foundation

extension GameStore {
    var widgetSnapshot: WidgetSnapshot {
        let index = min(119,max(0,data.lastLevel-1))
        let puzzle = Puzzle.levels[index]
        let icons = ["emoji:🍒","star.fill","bell.fill","bolt.fill","diamond.fill"]
        return WidgetSnapshot(title: Puzzle.rooms[puzzle.room], value: "\(puzzle.number)", label: "continue this level",
            detail: "\(data.completed) of 120 puzzles solved · \(puzzle.limit) moves allowed", footnote: "Target symbols · a logic puzzle",
            progress: Double(data.completed)/120, symbols: puzzle.target.map { icons[$0] })
    }
    func publishWidget() { WidgetStore.publish(widgetSnapshot) }
}

#if DEBUG && targetEnvironment(simulator)
extension GameStore {
    /// Only explicit UI-test launches in disposable simulators can mutate this fixture.
    func applyWidgetQA(_ url: URL) {
        guard ProcessInfo.processInfo.arguments.contains("-WidgetQA"),
              URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.contains(where: { $0.name == "qa" && ["1", "2"].contains($0.value ?? "") }) == true else { return }
        let secondUpdate = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.contains(where: { $0.name == "qa" && $0.value == "2" }) == true
        let puzzle = Puzzle.levels[secondUpdate ? 1 : 0]
        var attempt = Attempt(state: puzzle.start)
        for turn in puzzle.optimal { attempt.turn(turn, puzzle: puzzle) }
        update(attempt, for: puzzle)
        complete(puzzle, attempt: attempt)
    }
}
#endif
