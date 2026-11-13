import XCTest
@testable import NeonReels

final class EngineTests: XCTestCase {
    func testAll120LevelsAndOptimalityAgainstIndependentDistanceMap() {
        XCTAssertEqual(Puzzle.levels.count,120)
        XCTAssertEqual(Set(Puzzle.levels.map(\.id)).count,120)
        for p in Puzzle.levels {
            let path=p.optimal
            XCTAssertFalse(path.isEmpty)
            XCTAssertLessThanOrEqual(path.count,p.limit)
            XCTAssertEqual(path.reduce(p.start) { Engine.apply($1,to:$0,room:p.room) },p.target)
            // Independent reverse distance expansion verifies no shorter route exists.
            var frontier:Set<[Int]>=[p.target];var seen=frontier;var distance=0
            while !frontier.contains(p.start) {
                frontier=Set(frontier.flatMap { state in Engine.turns.map { Engine.apply($0,to:state,room:p.room) } }).subtracting(seen)
                seen.formUnion(frontier);distance += 1
                XCTAssertFalse(frontier.isEmpty);if frontier.isEmpty { break }
            }
            XCTAssertEqual(path.count,distance,p.id)
        }
    }
    func testAllStatesReachableAndTurnsReversible() {
        for room in 0..<3 {
            for a in 0..<5 { for b in 0..<5 { for c in 0..<5 {
                let state=[a,b,c]
                XCTAssertNotNil(Engine.solve([0,0,0],target:state,room:room))
                for turn in Engine.turns {
                    let moved=Engine.apply(turn,to:state,room:room)
                    XCTAssertEqual(Engine.apply(Turn(reel:turn.reel,direction:-turn.direction),to:moved,room:room),state)
                }
            } } }
        }
    }
    func testUndoLimitAndRestartSemantics() {
        let p=Puzzle.levels[0];var attempt=Attempt(state:p.start)
        for _ in 0..<p.limit+4 { attempt.turn(Turn(reel:0,direction:1),puzzle:p) }
        XCTAssertEqual(attempt.moves,p.limit)
        attempt.undo();XCTAssertEqual(attempt.moves,p.limit-1)
        while !attempt.history.isEmpty { attempt.undo() }
        attempt.undo();XCTAssertEqual(attempt.state,p.start);XCTAssertEqual(attempt.moves,0)
    }
    func testLinkedRulesAndHints() {
        XCTAssertEqual(Engine.apply(Turn(reel:0,direction:1),to:[0,0,0],room:1),[1,1,0])
        XCTAssertEqual(Engine.apply(Turn(reel:2,direction:-1),to:[0,0,0],room:2),[4,0,4])
        for p in Puzzle.levels {
            let moved=Engine.apply(Turn(reel:1,direction:-1),to:p.start,room:p.room)
            let hints=Engine.solve(moved,target:p.target,room:p.room)!
            XCTAssertEqual(hints.reduce(moved) { Engine.apply($1,to:$0,room:p.room) },p.target)
        }
    }
    func testRatingRecordsAndDailyDeterminism() throws {
        XCTAssertEqual(Engine.stars(moves:2,optimum:2),3)
        XCTAssertEqual(Engine.stars(moves:3,optimum:2),2)
        XCTAssertEqual(Engine.stars(moves:4,optimum:2),1)
        let p=Puzzle.levels[0];var data=ProgressData()
        data.record(p,moves:4);data.record(p,moves:2);data.record(p,moves:5)
        XCTAssertEqual(data.records[p.id]?.moves,2);XCTAssertEqual(data.completed,1)
        XCTAssertEqual(Puzzle.daily("2026-11-13"),Puzzle.daily("2026-11-13"))
        XCTAssertNotEqual(Puzzle.daily("2026-11-13").id,Puzzle.daily("2026-11-14").id)
        data.attempts[p.id]=Attempt(state:p.start)
        XCTAssertEqual(try JSONDecoder().decode(ProgressData.self,from:JSONEncoder().encode(data)).validated(),data)
    }
    @MainActor func testPersistenceReloadAndCorruptFileProtection() throws {
        let root=FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at:root) }
        let url=root.appendingPathComponent("progress.json")
        let first=GameStore(url:url);first.load()
        let p=Puzzle.levels[40];var attempt=Attempt(state:p.start);attempt.turn(Turn(reel:0,direction:1),puzzle:p)
        first.update(attempt,for:p)
        let second=GameStore(url:url);second.load();XCTAssertEqual(second.attempt(p),attempt)
        try Data("broken".utf8).write(to:url)
        let damaged=GameStore(url:url);damaged.load();XCTAssertNotNil(damaged.error)
        damaged.save();XCTAssertEqual(try String(contentsOf:url,encoding:.utf8),"broken")
        damaged.reset();XCTAssertNil(damaged.error)
        XCTAssertNoThrow(try JSONDecoder().decode(ProgressData.self,from:Data(contentsOf:url)))
    }
    func testMalformedStateRejected() throws {
        var d=ProgressData();d.attempts["level-1"]=Attempt(state:[9])
        XCTAssertThrowsError(try d.validated())
    }
}
